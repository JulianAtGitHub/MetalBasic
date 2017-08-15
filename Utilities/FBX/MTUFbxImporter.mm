//
//  MeshLoader.cpp
//  MetalSample
//
//  Created by zhuwei on 7/5/17.
//  Copyright © 2017 julian. All rights reserved.
//

#include <fbxsdk.h>
#import "../MTUTypes.h"
#import "../MTUShaderTypes.h"
#import "../MTUNode.h"
#import "../MTUMesh.h"
#import "MTUFbxImporter.h"

static bool LoadScene(FbxManager* pManager, FbxDocument* pScene, const char* pFilename)
{
    int lFileMajor, lFileMinor, lFileRevision;
    int lSDKMajor,  lSDKMinor,  lSDKRevision;
    //int lFileFormat = -1;
    int i, lAnimStackCount;
    bool lStatus;
    char lPassword[1024];
    
    // Get the file version number generate by the FBX SDK.
    FbxManager::GetFileFormatVersion(lSDKMajor, lSDKMinor, lSDKRevision);
    
    // Get IOSettings reference
    FbxIOSettings *lIOS = pManager->GetIOSettings();
    
    // Create an importer.
    FbxImporter* lImporter = FbxImporter::Create(pManager,"");
    
    // Initialize the importer by providing a filename.
    const bool lImportStatus = lImporter->Initialize(pFilename, -1, pManager->GetIOSettings());
    lImporter->GetFileVersion(lFileMajor, lFileMinor, lFileRevision);
    
    if( !lImportStatus )
    {
        FbxString error = lImporter->GetStatus().GetErrorString();
        NSLog(@"Call to FbxImporter::Initialize() failed.");
        NSLog(@"Error returned: %s\n", error.Buffer());
        
        if (lImporter->GetStatus().GetCode() == FbxStatus::eInvalidFileVersion)
        {
            NSLog(@"FBX file format version for this FBX SDK is %d.%d.%d", lSDKMajor, lSDKMinor, lSDKRevision);
            NSLog(@"FBX file format version for file '%s' is %d.%d.%d\n", pFilename, lFileMajor, lFileMinor, lFileRevision);
        }
        
        return false;
    }
    
    NSLog(@"FBX file format version for this FBX SDK is %d.%d.%d", lSDKMajor, lSDKMinor, lSDKRevision);
    
    if (lImporter->IsFBX())
    {
        NSLog(@"FBX file format version for file '%s' is %d.%d.%d\n", pFilename, lFileMajor, lFileMinor, lFileRevision);
        
        // From this point, it is possible to access animation stack information without
        // the expense of loading the entire file.
        
        NSLog(@"Animation Stack Information");
        
        lAnimStackCount = lImporter->GetAnimStackCount();
        
        NSLog(@"    Number of Animation Stacks: %d", lAnimStackCount);
        NSLog(@"    Current Animation Stack: \"%s\"\n", lImporter->GetActiveAnimStackName().Buffer());
        
        for(i = 0; i < lAnimStackCount; i++)
        {
            FbxTakeInfo* lTakeInfo = lImporter->GetTakeInfo(i);
            
            NSLog(@"    Animation Stack %d", i);
            NSLog(@"         Name: \"%s\"", lTakeInfo->mName.Buffer());
            NSLog(@"         Description: \"%s\"", lTakeInfo->mDescription.Buffer());
            
            // Change the value of the import name if the animation stack should be imported
            // under a different name.
            NSLog(@"         Import Name: \"%s\"", lTakeInfo->mImportName.Buffer());
            
            // Set the value of the import state to false if the animation stack should be not
            // be imported.
            NSLog(@"         Import State: %s\n", lTakeInfo->mSelect ? "true" : "false");
        }
        
        // Set the import states. By default, the import states are always set to
        // true. The code below shows how to change these states.
        lIOS->SetBoolProp(IMP_FBX_MATERIAL,        true);
        lIOS->SetBoolProp(IMP_FBX_TEXTURE,         true);
        lIOS->SetBoolProp(IMP_FBX_LINK,            true);
        lIOS->SetBoolProp(IMP_FBX_SHAPE,           true);
        lIOS->SetBoolProp(IMP_FBX_GOBO,            true);
        lIOS->SetBoolProp(IMP_FBX_ANIMATION,       true);
        lIOS->SetBoolProp(IMP_FBX_GLOBAL_SETTINGS, true);
    }
    
    // Import the scene.
    lStatus = lImporter->Import(pScene);
    
    if(lStatus == false && lImporter->GetStatus().GetCode() == FbxStatus::ePasswordError)
    {
        NSLog(@"Please enter password: ");
        
        lPassword[0] = '\0';
        
        FBXSDK_CRT_SECURE_NO_WARNING_BEGIN
        scanf("%s", lPassword);
        FBXSDK_CRT_SECURE_NO_WARNING_END
        
        FbxString lString(lPassword);
        
        lIOS->SetStringProp(IMP_FBX_PASSWORD,      lString);
        lIOS->SetBoolProp(IMP_FBX_PASSWORD_ENABLE, true);
        
        lStatus = lImporter->Import(pScene);
        
        if(lStatus == false && lImporter->GetStatus().GetCode() == FbxStatus::ePasswordError)
        {
            NSLog(@"Password is wrong, import aborted.");
        }
    }
    
    // Destroy the importer.
    lImporter->Destroy();
    
    return lStatus;
}

@interface MTUFbxImporter () {
    FbxManager *_sdkManager;
    MTUVertexFormat _vertexFormat;
}

- (void) initSdkManager;

- (MTUNode *) loadNodeFromFbxNode:(FbxNode *)root toParent:(MTUNode *)parent;

- (MTUMesh *) loadMeshFromFbxMesh:(FbxMesh *)mesh;

- (void) loadTexCoord:(FbxGeometryElementUV *)elementUV
           forAVertex:(void *)vertex
                index:(unsigned int)index
    controlPointIndex:(unsigned int)cpIndex;

- (void) loadNormal:(FbxGeometryElementNormal *)elementNormal
         forAVertex:(void *)vertex
              index:(unsigned int)index
  controlPointIndex:(unsigned int)cpIndex;

- (void) loadTangent:(FbxGeometryElementTangent *)elementTangent
         andBinormal:(FbxGeometryElementBinormal *)elementBinormal
          forAVertex:(void *)vertex
               index:(unsigned int)index
   controlPointIndex:(unsigned int)cpIndex;

@end

@implementation MTUFbxImporter

static MTUFbxImporter *instance = nil;

+ (MTUFbxImporter *) shadedInstance {
    if (instance == nil) {
        instance = [[MTUFbxImporter alloc] init];
    }
    return instance;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        [self initSdkManager];
    }
    return self;
}

- (void) initSdkManager {
    if (_sdkManager) {
        return;
    }
    
    //The first thing to do is to create the FBX Manager which is the object allocator for almost all the classes in the SDK
    _sdkManager = FbxManager::Create();
    if( !_sdkManager ) {
        NSLog(@"Error: Unable to create FBX Manager!");
        return;
    } else {
        NSLog(@"Autodesk FBX SDK version %s", _sdkManager->GetVersion());
    }
    
    //Create an IOSettings object. This object holds all import/export settings.
    FbxIOSettings* ios = FbxIOSettings::Create(_sdkManager, IOSROOT);
    _sdkManager->SetIOSettings(ios);
    
    //Load plugins from the executable directory (optional)
    FbxString path = FbxGetApplicationDirectory();
    _sdkManager->LoadPluginsDirectory(path.Buffer());
}

- (void) dealloc {
    //Delete the FBX Manager. All the objects that have been allocated using the FBX Manager and that haven't been explicitly destroyed are also automatically destroyed.
    if( _sdkManager ) {
        _sdkManager->Destroy();
    }
}

- (MTUNode *)loadNodeFromFile:(NSString *)filename andConvertToFormat:(MTUVertexFormat)format {
    _vertexFormat = (format == MTUVertexFormatInvalid ? MTUVertexFormatPTN : format);
    
    //Create an FBX scene. This object holds most objects imported/exported from/to files.
    FbxScene *scene = FbxScene::Create(_sdkManager, "Import Scene Root");
    if( !scene ) {
        NSLog(@"Error: Unable to create FBX scene!");
        return nil;
    }
    
    MTUNode *rootNode = nil;
    NSURL *fileurl = [[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:filename];
    bool result = LoadScene(_sdkManager, scene, [fileurl.path UTF8String]);
    
    if(result == false) {
        NSLog(@"An error occurred while loading the scene...");
    } else {
        FbxGeometryConverter converter(_sdkManager);
        if (!converter.Triangulate(scene, true)) {
            NSLog(@"Not all geometry of scene are convert to triangle...");
        }
        if (!converter.SplitMeshesPerMaterial(scene, true)) {
            NSLog(@"No mesh split for each material...");
        }
        rootNode = [self loadNodeFromFbxNode:scene->GetRootNode() toParent:nil];
    }
    
    // Destroy all objects created by the FBX SDK.
    scene->Destroy();
    
    return rootNode;
}

- (MTUNode *) loadNodeFromFbxNode:(FbxNode *)root toParent:(MTUNode *)parent {
    if (root == NULL) {
        return nil;
    }
    
    NSLog(@"Load FBX Node:%s", root->GetName());
    
    MTUNode *node = [[MTUNode alloc] initWithParent:parent];
    node.name = [NSString stringWithUTF8String:root->GetName()];
    
    for (int i = 0; i < root->GetNodeAttributeCount(); ++i) {
        FbxNodeAttribute *attribute = root->GetNodeAttributeByIndex(i);
        if (attribute->GetAttributeType() !=  FbxNodeAttribute::eMesh) {
            continue;
        }
        
        FbxMesh *fbxMesh = dynamic_cast<FbxMesh *>(attribute);
        MTUMesh *mesh = [self loadMeshFromFbxMesh:fbxMesh];
        if (mesh) {
            NSString *name = [NSString stringWithUTF8String:fbxMesh->GetName()];
            if (name.length == 0) {
                name = [NSString stringWithFormat:@"%@_mesh_%d", node.name, i];
            }
            mesh.name = name;
            NSLog(@"Load FBX Mesh:%@", name);
            [node addMesh:mesh];
        }
    }
    
    for (NSUInteger i = 0; i < root->GetChildCount(); ++i) {
        MTUNode *child = [self loadNodeFromFbxNode:root->GetChild(i) toParent:node];
        [node addChild:child];
    }
    
    return node;
}

- (MTUMesh *) loadMeshFromFbxMesh:(FbxMesh *)fbxMesh {
    if (fbxMesh == NULL) {
        return nil;
    }
    
    MTUMesh *mesh = nil;
    
    do {
        unsigned int triangleCount = fbxMesh->GetPolygonCount();
        if (triangleCount == 0) {
            break;
        }
        
        unsigned int vertexCount = triangleCount * 3;
        size_t vertexSize = 0;
        BOOL hasTexCoord = NO;
        BOOL hasNormal = NO;
        BOOL hasTangent = NO;
        switch (_vertexFormat) {
            case MTUVertexFormatP: {
                vertexSize = sizeof(MTUVertexP);
            } break;
            case MTUVertexFormatPT: {
                vertexSize = sizeof(MTUVertexPT);
                hasTexCoord = YES;
            } break;
            case MTUVertexFormatPTN: {
                vertexSize = sizeof(MTUVertexPTN);
                hasTexCoord = YES;
                hasNormal = YES;
            } break;
            case MTUVertexFormatPTNTB: {
                vertexSize = sizeof(MTUVertexPTNTB);
                hasTexCoord = YES;
                hasNormal = YES;
                hasTangent = YES;
            } break;
            default:
                break;
        }
        if (vertexSize == 0) {
            break;
        }
        
        //only load diffuse uv
        int uvIndex = 0;
        FbxGeometryElementUV *elementUV = fbxMesh->GetElementUV(uvIndex);
        if (elementUV == NULL) {
            NSLog(@"FBX Mesh:%s don't have uv element!", fbxMesh->GetName());
        }
        
        FbxGeometryElementNormal *elementNormal = fbxMesh->GetElementNormal();
        if (elementNormal == NULL) {
            NSLog(@"FBX Mesh:%s don't have normal element, try to generate!", fbxMesh->GetName());
            
            if (fbxMesh->GenerateNormals(true, false, true)) {
                elementNormal = fbxMesh->GetElementNormal();
            } else {
                NSLog(@"FBX Mesh:%s generate normal element failed!", fbxMesh->GetName());
            }
        }
        
        FbxGeometryElementTangent *elementTangent = fbxMesh->GetElementTangent();
        FbxGeometryElementBinormal *elementBinormal = fbxMesh->GetElementBinormal();
        if (hasTangent == YES && elementTangent == NULL) {
            NSLog(@"FBX Mesh:%s don't have tangent element, try to generate!", fbxMesh->GetName());
            
            if (fbxMesh->GenerateTangentsData(uvIndex)) {
                elementTangent = fbxMesh->GetElementTangent();
                elementBinormal = fbxMesh->GetElementBinormal();
            } else {
                NSLog(@"FBX Mesh:%s generate normal element failed!", fbxMesh->GetName());
            }
        }
        
        void *vertices = calloc(vertexCount, vertexSize);
        
        for (unsigned int i = 0; i < vertexCount; ++i) {
            unsigned int cpIndex = fbxMesh->GetPolygonVertex(i / 3, i % 3);
            
            void *vertex = (char *)vertices + (vertexSize * i);
            
            // read position
            FbxVector4 position = fbxMesh->GetControlPointAt(cpIndex);
            MTUPoint3 *vPosition = NULL;
            switch (_vertexFormat) {
                case MTUVertexFormatP: vPosition = &(((MTUVertexP *)vertex)->position); break;
                case MTUVertexFormatPT: vPosition = &(((MTUVertexPT *)vertex)->position); break;
                case MTUVertexFormatPTN: vPosition = &(((MTUVertexPTN *)vertex)->position); break;
                case MTUVertexFormatPTNTB: vPosition = &(((MTUVertexPTNTB *)vertex)->position); break;
                default: break;
            }
            if (vPosition != NULL) {
                (*vPosition).x = position.mData[0];
                (*vPosition).y = position.mData[1];
                (*vPosition).z = position.mData[2];
            }
            
            // read texture coord
            if (hasTexCoord == YES) {
                [self loadTexCoord:elementUV forAVertex:vertex index:i controlPointIndex:cpIndex];
            }
            
            // read nromal
            if (hasNormal) {
                [self loadNormal:elementNormal forAVertex:vertex index:i controlPointIndex:cpIndex];
            }
            
            // read tangent and binormal
            if (hasTangent) {
                [self loadTangent:elementTangent andBinormal:elementBinormal forAVertex:vertex index:i controlPointIndex:cpIndex];
            }

        }
        
        NSData *rawData = [NSData dataWithBytesNoCopy:vertices length:(vertexCount * vertexSize)];
        mesh = [[MTUMesh alloc] initWithVertexData:rawData andVertexFormat:_vertexFormat];
        
    } while (0);
    
    
    return mesh;
}

- (void) loadTexCoord:(FbxGeometryElementUV *)elementUV
           forAVertex:(void *)vertex
                index:(unsigned int)index
    controlPointIndex:(unsigned int)cpIndex {
    if (elementUV == NULL || vertex == NULL) {
        return;
    }
    
    int uvIndex = -1;
    switch (elementUV->GetMappingMode()) {
        case FbxGeometryElement::eByControlPoint: {
            switch (elementUV->GetReferenceMode()) {
                case FbxGeometryElement::eDirect:
                    uvIndex = cpIndex;
                    break;
                case FbxGeometryElement::eIndexToDirect:
                    uvIndex = elementUV->GetIndexArray().GetAt(cpIndex);
                    break;
                default:
                    break;
            }
        } break;
            
        case FbxGeometryElement::eByPolygonVertex: {
            switch (elementUV->GetReferenceMode()) {
                case FbxGeometryElement::eDirect:
                    uvIndex = index;
                    break;
                case FbxGeometryElement::eIndexToDirect:
                    uvIndex = elementUV->GetIndexArray().GetAt(index);
                    break;
                default:
                    break;
            }
        } break;
            
        default:
            break;
    }
    
    // update texCoord
    if (uvIndex >= 0) {
        FbxVector2 uv = elementUV->GetDirectArray().GetAt(uvIndex);
        MTUPoint2 *vTexCoord = NULL;
        switch (_vertexFormat) {
            case MTUVertexFormatPT: vTexCoord = &(((MTUVertexPT *)vertex)->texCoord); break;
            case MTUVertexFormatPTN: vTexCoord = &(((MTUVertexPTN *)vertex)->texCoord); break;
            case MTUVertexFormatPTNTB: vTexCoord = &(((MTUVertexPTNTB *)vertex)->texCoord); break;
            default: break;
        }
        if (vTexCoord != NULL) {
            (*vTexCoord).x = uv.mData[0];
            (*vTexCoord).y = uv.mData[1];
        }
    }
}

- (void) loadNormal:(FbxGeometryElementNormal *)elementNormal
         forAVertex:(void *)vertex
              index:(unsigned int)index
  controlPointIndex:(unsigned int)cpIndex {
    if (elementNormal == NULL || vertex == NULL) {
        return;
    }
    
    int normalIndex = -1;
    switch (elementNormal->GetMappingMode()) {
        case FbxGeometryElement::eByControlPoint: {
            switch (elementNormal->GetReferenceMode()) {
                case FbxGeometryElement::eDirect:
                    normalIndex = cpIndex;
                    break;
                case FbxGeometryElement::eIndexToDirect:
                    normalIndex = elementNormal->GetIndexArray().GetAt(cpIndex);
                    break;
                default:
                    break;
            }
        } break;
            
        case FbxGeometryElement::eByPolygonVertex: {
            switch (elementNormal->GetReferenceMode()) {
                case FbxGeometryElement::eDirect:
                    normalIndex = index;
                    break;
                case FbxGeometryElement::eIndexToDirect:
                    normalIndex = elementNormal->GetIndexArray().GetAt(index);
                    break;
                default:
                    break;
            }
        } break;
            
        default:
            break;
    }
    if (normalIndex >= 0) {
        FbxVector4 normal = elementNormal->GetDirectArray().GetAt(normalIndex);
        MTUPoint3 *vNormal = NULL;
        switch (_vertexFormat) {
            case MTUVertexFormatPTN: vNormal = &(((MTUVertexPTN *)vertex)->normal); break;
            case MTUVertexFormatPTNTB: vNormal = &(((MTUVertexPTNTB *)vertex)->normal); break;
            default: break;
        }
        if (vNormal != NULL) {
            (*vNormal).x = normal.mData[0];
            (*vNormal).y = normal.mData[1];
            (*vNormal).z = normal.mData[2];
        }
    }
}

- (void) loadTangent:(FbxGeometryElementTangent *)elementTangent
         andBinormal:(FbxGeometryElementBinormal *)elementBinormal
          forAVertex:(void *)vertex
               index:(unsigned int)index
   controlPointIndex:(unsigned int)cpIndex {
    if (elementTangent == NULL || elementBinormal == NULL || vertex == NULL) {
        return;
    }
    
    int tangentIndex = -1;
    switch (elementTangent->GetMappingMode()) {
        case FbxGeometryElement::eByControlPoint: {
            switch (elementTangent->GetReferenceMode()) {
                case FbxGeometryElement::eDirect:
                    tangentIndex = cpIndex;
                    break;
                case FbxGeometryElement::eIndexToDirect:
                    tangentIndex = elementTangent->GetIndexArray().GetAt(cpIndex);
                    break;
                default:
                    break;
            }
        } break;
            
        case FbxGeometryElement::eByPolygonVertex: {
            switch (elementTangent->GetReferenceMode()) {
                case FbxGeometryElement::eDirect:
                    tangentIndex = index;
                    break;
                case FbxGeometryElement::eIndexToDirect:
                    tangentIndex = elementTangent->GetIndexArray().GetAt(index);
                    break;
                default:
                    break;
            }
        } break;
            
        default:
            break;
    }
    
    if (tangentIndex >= 0) {
        FbxVector4 tangent = elementTangent->GetDirectArray().GetAt(tangentIndex);
        FbxVector4 binormal = elementBinormal->GetDirectArray().GetAt(tangentIndex);
        MTUVertexPTNTB *vertexPTNTB = (MTUVertexPTNTB *)vertex;
        vertexPTNTB->tangent.x = tangent.mData[0];
        vertexPTNTB->tangent.y = tangent.mData[1];
        vertexPTNTB->tangent.z = tangent.mData[2];
        vertexPTNTB->binormal.x = binormal.mData[0];
        vertexPTNTB->binormal.y = binormal.mData[1];
        vertexPTNTB->binormal.z = binormal.mData[2];
    }
}

@end

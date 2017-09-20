#include <jni.h>
#include "SSLKernelItem.h"

#ifdef __cplusplus
extern "C" {
#endif
/*
 * Class:     TencentECCEngine
 * Method:    CreateECDSAKey
 * Signature: (Ljava/lang/String;)I
 */
JNIEXPORT jint JNICALL Java_TencentECCEngine_CreateECDSAKey(JNIEnv * env,
		jclass cls, jstring strFilePath) {
	int ret = 0;
	if (strFilePath == NULL)
		return ret;
	const char* pStrPath = env->GetStringUTFChars(strFilePath, NULL);
	CreateECDSAKey(pStrPath);
	env->ReleaseStringUTFChars(strFilePath, pStrPath);
	return ret;
}

/*
 * Class:     TencentECCEngine
 * Method:    ECDSASignToBuffer
 * Signature: (Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
 */
JNIEXPORT jstring JNICALL Java_TencentECCEngine_ECDSASignToBuffer(JNIEnv * env,
		jclass cls, jstring strPrivateKeyPath, jstring strBufferData) {
	if (strPrivateKeyPath == NULL || strBufferData == NULL)
		return NULL;

	const char* pStrPrivateKeyPath = env->GetStringUTFChars(strPrivateKeyPath, NULL);
	const char* pStrBufferData = env->GetStringUTFChars(strBufferData, NULL);
	char szLicenceBuffer[1024] = {0};
	unsigned int nLicencelen = 0;

	int bRet = ECDSASignToBuffer((char*)pStrPrivateKeyPath,(char*)pStrBufferData, strlen(pStrBufferData), szLicenceBuffer, &nLicencelen);

	env->ReleaseStringUTFChars(strPrivateKeyPath, pStrPrivateKeyPath);
	env->ReleaseStringUTFChars(strBufferData, pStrBufferData);
	if (bRet == 1) {
		return env->NewStringUTF(szLicenceBuffer);
	} else {
		return NULL;
	}
}

/*
 * Class:     TencentECCEngine
 * Method:    ECDSASignFileToLicenceFile
 * Signature: (Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)I
 */
JNIEXPORT jint JNICALL Java_TencentECCEngine_ECDSASignFileToLicenceFile(
		JNIEnv * env, jclass cls, jstring strPrivateKeyPath,
		jstring strDataFilePath, jstring strLicencePath) {
	if (strPrivateKeyPath == NULL || strDataFilePath == NULL || strLicencePath == NULL)
		return 0;

	const char* pStrPrivateKeyPath = env->GetStringUTFChars(strPrivateKeyPath, NULL);
	const char* pStrDataFilePath = env->GetStringUTFChars(strDataFilePath, NULL);
	const char* pStrLicencePath = env->GetStringUTFChars(strLicencePath, NULL);

	int nRet = ECDSASignFileToLicenceFile(pStrPrivateKeyPath, pStrDataFilePath, pStrLicencePath);

	env->ReleaseStringUTFChars(strPrivateKeyPath, pStrPrivateKeyPath);
	env->ReleaseStringUTFChars(strDataFilePath, pStrDataFilePath);
	env->ReleaseStringUTFChars(strLicencePath, pStrLicencePath);

	return nRet;
}

/*
 * Class:     TencentECCEngine
 * Method:    ECDSASignBufferToLicenceFile
 * Signature: (Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)I
 */
JNIEXPORT jint JNICALL Java_TencentECCEngine_ECDSASignBufferToLicenceFile(
		JNIEnv * env, jclass cls, jstring strPrivateKeyPath, jstring strBufferData, jstring strLicencePath)
{
	if (strPrivateKeyPath == NULL || strBufferData == NULL || strLicencePath == NULL)
			return 0;

	const char* pStrPrivateKeyPath = env->GetStringUTFChars(strPrivateKeyPath, NULL);
	const char* pStrBufferData = env->GetStringUTFChars(strBufferData, NULL);
	const char* pStrLicencePath = env->GetStringUTFChars(strLicencePath, NULL);

	int nRet = ECDSASignBufferToLicenceFile(pStrPrivateKeyPath, (char*)pStrBufferData, strlen(pStrBufferData), pStrLicencePath);
	
	env->ReleaseStringUTFChars(strPrivateKeyPath, pStrPrivateKeyPath);
	env->ReleaseStringUTFChars(strBufferData, pStrBufferData);
	env->ReleaseStringUTFChars(strLicencePath, pStrLicencePath);
	return nRet;
}

/*
 * Class:     TencentECCEngine
 * Method:    ECDSASignBufferBase16ToLicenceFile
 * Signature: (Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)I
 */
JNIEXPORT jint JNICALL Java_TencentECCEngine_ECDSASignBufferBase16ToLicenceFile(
		JNIEnv * env, jclass cls, jstring strPrivateKeyPath, jstring strBufferData, jstring strLicencePath)
{
	if (strPrivateKeyPath == NULL || strBufferData == NULL|| strLicencePath == NULL)
		return 0;

	const char* pStrPrivateKeyPath = env->GetStringUTFChars(strPrivateKeyPath, NULL);
	const char* pStrBufferData = env->GetStringUTFChars(strBufferData, NULL);
	const char* pStrLicencePath = env->GetStringUTFChars(strLicencePath, NULL);

	int nRet = ECDSASignBufferBase16ToLicenceFile(pStrPrivateKeyPath, (char*)pStrBufferData, strlen(pStrBufferData), pStrLicencePath);
	
	env->ReleaseStringUTFChars(strPrivateKeyPath, pStrPrivateKeyPath);
	env->ReleaseStringUTFChars(strBufferData, pStrBufferData);
	env->ReleaseStringUTFChars(strLicencePath, pStrLicencePath);
	return nRet;
}

/*
 * Class:     TencentECCEngine
 * Method:    ECDSAVerifyLicenceBuffer
 * Signature: (Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)I
 */
JNIEXPORT jint JNICALL Java_TencentECCEngine_ECDSAVerifyLicenceBuffer(
		JNIEnv * env, jclass cls, jstring strPublicKeyPath, jstring strBufferData, jstring strLicenceData)
{
	if (strPublicKeyPath == NULL || strBufferData == NULL|| strLicenceData == NULL)
			return 0;

	const char* pStrPublicKeyPath = env->GetStringUTFChars(strPublicKeyPath, NULL);
	const char* pStrBufferData = env->GetStringUTFChars(strBufferData, NULL);
	const char* pStrLicenceData = env->GetStringUTFChars(strLicenceData, NULL);

	int nRet = ECDSAVerifyLicenceBuffer((char*)pStrPublicKeyPath, (char*)pStrBufferData, strlen(pStrBufferData), (char*)pStrLicenceData, strlen(pStrLicenceData));

	env->ReleaseStringUTFChars(strPublicKeyPath, pStrPublicKeyPath);
	env->ReleaseStringUTFChars(strBufferData, pStrBufferData);
	env->ReleaseStringUTFChars(strLicenceData, pStrLicenceData);
	return nRet;
}

/*
 * Class:     TencentECCEngine
 * Method:    ECDSAVerifyLicenceFile
 * Signature: (Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)I
 */
JNIEXPORT jint JNICALL Java_TencentECCEngine_ECDSAVerifyLicenceFile(
		JNIEnv * env, jclass cls, jstring strPublicKeyPath,  jstring strDataFilePath, jstring strLicencePath)
{
	if (strPublicKeyPath == NULL || strDataFilePath == NULL|| strLicencePath == NULL)
			return 0;

	const char* pStrPublicKeyPath = env->GetStringUTFChars(strPublicKeyPath, NULL);
	const char* pStrDataFilePath = env->GetStringUTFChars(strDataFilePath, NULL);
	const char* pStrLicencePath = env->GetStringUTFChars(strLicencePath, NULL);

	int ret = ECDSAVerifyLicenceFile(pStrPublicKeyPath, pStrDataFilePath, pStrLicencePath);
	
	env->ReleaseStringUTFChars(strPublicKeyPath, pStrPublicKeyPath);
	env->ReleaseStringUTFChars(strDataFilePath, pStrDataFilePath);
	env->ReleaseStringUTFChars(strLicencePath, pStrLicencePath);
	return ret;
}

/*
 * Class:     TencentECCEngine
 * Method:    ECDSAVerifyBase16LicenceFile
 * Signature: (Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)I
 */
JNIEXPORT jint JNICALL Java_TencentECCEngine_ECDSAVerifyBase16LicenceFile(
		JNIEnv * env, jclass cls, jstring strPublicKeyPath,  jstring strDataFilePath, jstring strLicencePath)
{
	if (strPublicKeyPath == NULL || strDataFilePath == NULL|| strLicencePath == NULL)
				return 0;

	const char* pStrPublicKeyPath = env->GetStringUTFChars(strPublicKeyPath, NULL);
	const char* pStrDataFilePath = env->GetStringUTFChars(strDataFilePath, NULL);
	const char* pStrLicencePath = env->GetStringUTFChars(strLicencePath, NULL);

	int ret = ECDSAVerifyBase16LicenceFile(pStrPublicKeyPath, pStrDataFilePath, pStrLicencePath);

	env->ReleaseStringUTFChars(strPublicKeyPath, pStrPublicKeyPath);
	env->ReleaseStringUTFChars(strDataFilePath, pStrDataFilePath);
	env->ReleaseStringUTFChars(strLicencePath, pStrLicencePath);
	return ret;
}

/*
 * Class:     TencentECCEngine
 * Method:    GetECDHShareKeyFromSrvPublicKey
 * Signature: (Ljava/lang/String;)[Ljava/lang/String;
 */
JNIEXPORT jobjectArray JNICALL Java_TencentECCEngine_GetECDHShareKeyFromSrvPublicKey(
		JNIEnv * env, jclass cls, jstring strSrvPublicKey)
{
	if (strSrvPublicKey == NULL)
		return NULL;

	const char* pStrSrvPublicKey = env->GetStringUTFChars(strSrvPublicKey, NULL);
	
	char szSharekey[1024] = {0};
	char szClientPubKey[1024] = {0};
	int nClientPubKeylen = 0;
	int nResult = GetECDHShareKeyFromSrvPublicKey(pStrSrvPublicKey, strlen(pStrSrvPublicKey), szSharekey, szClientPubKey, &nClientPubKeylen);
	

	env->ReleaseStringUTFChars(strSrvPublicKey, pStrSrvPublicKey);
	if (nResult == 1 && nClientPubKeylen > 0) {
		jobjectArray stringArray;
		stringArray = env->NewObjectArray(2, env->FindClass("java/lang/String"), env->NewStringUTF(""));
		env->SetObjectArrayElement(stringArray, 0, env->NewStringUTF(szSharekey));
		env->SetObjectArrayElement(stringArray, 1, env->NewStringUTF(szClientPubKey));
		return stringArray;
	} else {
		return NULL;
	}
}

#ifdef __cplusplus
}
#endif

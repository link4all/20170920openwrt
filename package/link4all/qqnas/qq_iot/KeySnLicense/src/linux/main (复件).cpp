#include "hashmd5.h"
#include "SSLKernelItem.h"

int main()
{
	CreateECDSAKey("./");
	ECDSASignBufferBase16ToLicenceFile("../ec_key.pem", "0EC8EFD8293E4b4d", strlen("0EC8EFD8293E4b4d"), "../license11.txt");
	// 根据公钥文件public.pem，验证guid.txt中的sn和license.txt是不是匹配
	int nRet = ECDSAVerifyBase16LicenceFile("../public.pem", "../../guid.txt", "../license.txt");
	if(nRet == 1)
	{
		printf("验证成功\n", nRet);
	}
	else 
	{
		printf("验证失败，错误码[%d]\n", nRet);
	}
	return 0;
}

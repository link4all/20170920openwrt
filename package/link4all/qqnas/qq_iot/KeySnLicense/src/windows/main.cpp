#include "../SSLKernelItem.h"
#include <tchar.h>

int _tmain(int argc, _TCHAR* argv[])
{
	CreateECDSAKey("./");
	ECDSASignBufferBase16ToLicenceFile("./ec_key.pem", "carol-0000000001", strlen("carol-0000000001"), "./license.txt");
	int nRet = ECDSAVerifyBase16LicenceFile("./public.pem", "../../../guid.txt", "./license.txt");
	if(nRet == 1)
	{
		printf("验证成功\n");
	}
	else 
	{
		printf("验证失败，错误码:[%d]\n", nRet);
	}
	getchar();
	return 0;
}
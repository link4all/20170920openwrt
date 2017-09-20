#include <stdio.h>
#include <crypt.h>
#include <pwd.h>
#include <shadow.h>

int sysauth(const char * username, const char * password) {
	struct spwd *pwd;
	if (getuid() != 0) {
		printf("You need to be root!\n");
		return(1);
	}

	pwd = getspnam(username);
	if (!pwd) {
		printf("User no esxit\n");
		return(1);
	}
	return strcmp(crypt(password, pwd->sp_pwdp), pwd->sp_pwdp);
}

int main(int argc, char **argv) {
	int ret = sysauth(argv[1], argv[2]);
	return(ret);
}

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <windows.h>

#define MAX 1024

int StrLRTrim(char* pStr);
int RegistryPathSplit(char *strRegistryFullPath
					  ,char *strRegPrimaryKey
					  ,char *strRegPath
					  ,char *strRegItem);


HKEY OpenRegKey(char *strKey,char *strSubKey,char *strRegistryPath);

FILE *g_pInFile = NULL;
FILE *g_pOutFile = NULL;

int main(int argc,char *argv[])
{
	char strRegistryFullPath[MAX];
	fopen_s(&g_pInFile,"input.txt","r");
	fopen_s(&g_pOutFile,"output.reg","w+");
	if(!g_pInFile)
	{
		return 0;
	}

	if (!g_pOutFile)
	{
		fclose(g_pInFile);
		g_pInFile = NULL;
		return 0;
	}

	fprintf(g_pOutFile,"Windows Registry Editor Version 5.00\n\n");

	while (fgets(strRegistryFullPath,MAX,g_pInFile))
	{
		char strRegPrimaryKey[MAX] ={0}
			,strRegPath[MAX] ={0}
			,strRegItem[MAX] ={0};
		HKEY hRegKey = NULL;

		StrLRTrim(strRegistryFullPath);
		if(strlen(strRegistryFullPath)<1)
		{
			continue;
		}

		printf("%s\n",strRegistryFullPath);

		RegistryPathSplit(strRegistryFullPath
							,strRegPrimaryKey
							,strRegPath
							,strRegItem);
		if((strlen(strRegPrimaryKey)<1)
			|| (strlen(strRegPath)<1 && strlen(strRegItem)<1))
		{
			continue;
		}
		printf("[%s]\n[%s]\n[%s]\n\n",strRegPrimaryKey
									,strRegPath
									,strRegItem);

		hRegKey = OpenRegKey(strRegPrimaryKey,strRegPath,strRegistryFullPath);
		if(hRegKey)
		{
			DWORD dwType,dwLen;
			unsigned char *data = NULL;

			RegQueryValueExA(hRegKey,strRegItem,0,&dwType,NULL,&dwLen);
			data = (unsigned char*)malloc(dwLen);
			if(ERROR_SUCCESS  == RegQueryValueExA(hRegKey,strRegItem,0,&dwType,(LPBYTE)data,&dwLen))
			{
				fprintf(g_pOutFile,"[%s]\n",strRegistryFullPath);
				if (strlen(strRegItem) < 1)
				{
					fprintf(g_pOutFile,"@=");
				}
				else	
				{
					int i = 0;
					fprintf(g_pOutFile,"\"");
					for(i = 0 ; i < (int)strlen(strRegItem) ; i++)
					{
						if(strRegItem[i] == '\\')
						{
							fprintf(g_pOutFile,"\\");
						}
						fprintf(g_pOutFile,"%c",strRegItem[i]);
					}
					fprintf(g_pOutFile,"\"=");
				}

				if(dwType == REG_BINARY)
				{
					DWORD i = 0;
					int nFlag = 19;

					fprintf(g_pOutFile,"hex:");
					for(i = 0 ; i < dwLen ; i ++)
					{
						nFlag --;
						if(nFlag < 0)
						{
							nFlag = 24;
							fprintf(g_pOutFile,"\\\n");
						}
						fprintf(g_pOutFile,"%02x",data[i]);//19,25..
						if(i < dwLen - 1)
						{
							fprintf(g_pOutFile,",");
						}
					}
				}
				else if(dwType == REG_SZ)
				{
					DWORD i = 0;

					fprintf(g_pOutFile,"\"");
					for(i = 0 ; i < dwLen ; i ++)
					{				
						if (data[i] == '\\')
						{
							fprintf(g_pOutFile,"\\");
						}
						if(data[i] == '\0')
						{
							break;
						}
						fprintf(g_pOutFile,"%c",data[i]);
					}
					fprintf(g_pOutFile,"\"");
				}
				else if (dwType == REG_DWORD)
				{
					DWORD temp;
					memcpy_s(&temp,sizeof(temp),data,sizeof(DWORD));
					fprintf(g_pOutFile,"dword:");
					fprintf(g_pOutFile,"%08x",temp);
				}
				else if (dwType == REG_MULTI_SZ || dwType == REG_EXPAND_SZ)
				{
					wchar_t wstrRegItem[MAX] = {0};
					DWORD dwCurType,dwCurLen;
					unsigned char *cdata = NULL;

					MultiByteToWideChar(CP_ACP,0,strRegItem,strlen(strRegItem)*sizeof(char),wstrRegItem,MAX*sizeof(wchar_t));
					RegQueryValueExW(hRegKey,wstrRegItem,0,&dwCurType,NULL,&dwCurLen);
					cdata = (unsigned char*)malloc(dwCurLen);
					if(ERROR_SUCCESS  == RegQueryValueExW(hRegKey,wstrRegItem,0,&dwType,(LPBYTE)cdata,&dwCurLen))
					{
						DWORD i = 0;
						if (dwType == REG_MULTI_SZ)
						{
							fprintf(g_pOutFile,"hex(7):");
						}
						else
						{
							fprintf(g_pOutFile,"hex(2):");
						}
						for(i = 0 ; i < dwCurLen ; i ++)
						{
							fprintf(g_pOutFile,"%02x",cdata[i]);
							if(i< dwCurLen - 1)
							{
								fprintf(g_pOutFile,",");
							}
						}
					}
					free(cdata);
				}

				fprintf(g_pOutFile,"\n\n");
			}
			else
			{
				if (strlen(strRegItem) < 1)
				{
					fprintf(g_pOutFile,"[%s]\n\n",strRegistryFullPath);
				}
			}

			free(data);
			RegCloseKey(hRegKey);
		}
		memset(strRegistryFullPath,0,MAX*sizeof(char));
	}
	

	fclose(g_pInFile);
	fclose(g_pOutFile);
	g_pInFile = NULL;
	g_pOutFile = NULL;
	return 0;
}

int RegistryPathSplit(char *strRegistryFullPath
					  ,char *strRegPrimaryKey
					  ,char *strRegPath
					  ,char *strRegItem)
{
	char *buf = strRegistryFullPath;
	char *strRe,*pNext = NULL;

	strRe = strtok_s(buf, "\\",&pNext);
	memcpy_s(strRegPrimaryKey,MAX*sizeof(char),strRe,(strlen(strRe)+1)*sizeof(char));
	memset(strRegPath,0,MAX*sizeof(char));
	memset(strRegItem,0,MAX*sizeof(char));
	while ((strRe = strtok_s(NULL, "\\",&pNext)) != NULL)
	{
		if(strlen(strRegItem) > 0)
		{
			strcat_s(strRegPath,MAX*sizeof(char),strRegItem);
			strcat_s(strRegPath,MAX*sizeof(char),"\\");
		}
		memcpy_s(strRegItem,MAX*sizeof(char),strRe,(strlen(strRe)+1)*sizeof(char));
	}
	if(strlen(strRegPath)>0)
	{
		strRegPath[strlen(strRegPath)-1] = '\0';
	}
	if (strcmp(strRegItem,"(Default)") == 0)
	{
		memset(strRegItem,0 ,MAX*sizeof(char));
	}
	return 0;
}

int StrLRTrim(char* pStr)
{
	char *pTmp = pStr+strlen(pStr)-1;  
      
    while (*pTmp == ' ' || *pTmp == '\r' || *pTmp == '\n')
    {  
        *pTmp = '\0';  
        pTmp--;  
    }

	pTmp = pStr;  
    while (*pTmp == ' ' || *pTmp == '\r' || *pTmp == '\n')
    {  
        pTmp++;
    }  
    while(*pTmp != '\0')
    {  
        *pStr = *pTmp;
        pStr++;
        pTmp++;
    }  
    *pStr = '\0';
	return 0;
}

HKEY OpenRegKey(char *strKey,char *strSubKey,char *strRegistryPath)
{
	HKEY hkey = NULL;
	memset(strRegistryPath,0,MAX*sizeof(char));
	if (strcmp(strKey,"HKCR") == 0)
	{
		sprintf_s(strRegistryPath,MAX*sizeof(char),"HKEY_CLASSES_ROOT\\%s",strSubKey);
		if(ERROR_SUCCESS != RegOpenKeyExA(HKEY_CLASSES_ROOT,strSubKey,0,KEY_ALL_ACCESS|KEY_WOW64_64KEY,&hkey))
		{
			hkey = NULL;
			return hkey;
		}
	}
	else if (strcmp(strKey,"HKCU") == 0)
	{
		sprintf_s(strRegistryPath,MAX*sizeof(char),"HKEY_CURRENT_USER\\%s",strSubKey);
		if(ERROR_SUCCESS != RegOpenKeyExA(HKEY_CURRENT_USER,strSubKey,0,KEY_ALL_ACCESS|KEY_WOW64_64KEY,&hkey))
		{
			hkey = NULL;
			return hkey;
		}
	}
	else if (strcmp(strKey,"HKLM") == 0)
	{
		sprintf_s(strRegistryPath,MAX*sizeof(char),"HKEY_LOCAL_MACHINE\\%s",strSubKey);
		if(ERROR_SUCCESS != RegOpenKeyExA(HKEY_LOCAL_MACHINE,strSubKey,0,KEY_ALL_ACCESS|KEY_WOW64_64KEY,&hkey))
		{
			hkey = NULL;
			return hkey;
		}
	}
	else if (strcmp(strKey,"HKU") == 0)
	{
		sprintf_s(strRegistryPath,MAX*sizeof(char),"HKEY_USERS\\%s",strSubKey);
		if(ERROR_SUCCESS != RegOpenKeyExA(HKEY_USERS,strSubKey,0,KEY_ALL_ACCESS|KEY_WOW64_64KEY,&hkey))
		{
			hkey = NULL;
			return hkey;
		}
	}
	else if (strcmp(strKey,"HKCC") == 0)
	{
		sprintf_s(strRegistryPath,MAX*sizeof(char),"HKEY_CURRENT_CONFIG\\%s",strSubKey);
		if(ERROR_SUCCESS != RegOpenKeyExA(HKEY_CURRENT_CONFIG,strSubKey,0,KEY_ALL_ACCESS|KEY_WOW64_64KEY,&hkey))
		{
			hkey = NULL;
			return hkey;
		}
	}

	return hkey;
}
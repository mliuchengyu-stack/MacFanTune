// AppleSMC protocol adapted from raminsharifi/MacFanControl (MIT).
#include <IOKit/IOKitLib.h>
#include <CoreFoundation/CoreFoundation.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <math.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <sys/stat.h>
#include <errno.h>
#include <time.h>

typedef struct { uint8_t major,minor,build,reserved; uint16_t release; } SMCVersion;
typedef struct { uint16_t version,length; uint32_t cpu,gpu,mem; } PLimit;
typedef struct { uint32_t size,type; uint8_t attrs; } KeyInfo;
typedef struct { uint32_t key; SMCVersion vers; PLimit limit; KeyInfo info; uint8_t result,status,data8; uint32_t data32; uint8_t bytes[32]; } SMCData;
_Static_assert(sizeof(SMCData)==80,"SMC ABI must be 80 bytes");
typedef struct { uint32_t type,size; uint8_t bytes[32]; } Value;
static io_connect_t conn=0;
static uint32_t fourcc(const char*s){return ((uint32_t)(uint8_t)s[0]<<24)|((uint32_t)(uint8_t)s[1]<<16)|((uint32_t)(uint8_t)s[2]<<8)|(uint8_t)s[3];}
static int call(SMCData*in,SMCData*out){size_t n=sizeof(*out);memset(out,0,sizeof(*out));kern_return_t k=IOConnectCallStructMethod(conn,2,in,sizeof(*in),out,&n);if(k)return (int)k;return out->result?0x10000|out->result:0;}
static int open_smc(void){io_service_t s=IOServiceGetMatchingService(kIOMainPortDefault,IOServiceMatching("AppleSMC"));if(!s)return -1;kern_return_t k=IOServiceOpen(s,mach_task_self(),0,&conn);IOObjectRelease(s);return (int)k;}
static int info(const char*k,KeyInfo*i){SMCData in={0},out={0};in.key=fourcc(k);in.data8=9;int e=call(&in,&out);if(!e)*i=out.info;return e;}
static int read_key(const char*k,Value*v){KeyInfo i={0};int e=info(k,&i);if(e)return e;SMCData in={0},out={0};in.key=fourcc(k);in.info.size=i.size;in.data8=5;e=call(&in,&out);if(!e){v->type=i.type;v->size=i.size;memcpy(v->bytes,out.bytes,32);}return e;}
static int write_key(const char*k,const void*b,size_t n){KeyInfo i={0};int e=info(k,&i);if(e)return e;if(i.size!=n)return -2;SMCData in={0},out={0};in.key=fourcc(k);in.info.size=i.size;in.data8=6;memcpy(in.bytes,b,n);return call(&in,&out);}
static uint32_t uint_value(Value*v){if(v->size==1)return v->bytes[0];if(v->size==2)return ((uint32_t)v->bytes[0]<<8)|v->bytes[1];return ((uint32_t)v->bytes[0]<<24)|((uint32_t)v->bytes[1]<<16)|((uint32_t)v->bytes[2]<<8)|v->bytes[3];}
static float rpm_value(Value*v){if(v->type==fourcc("flt ")){float f;memcpy(&f,v->bytes,4);return f;}if(v->type==fourcc("fpe2"))return (float)(((uint16_t)v->bytes[0]<<8)|v->bytes[1])/4.f;return (float)uint_value(v);}
static int fan_count(void){Value v={0};return read_key("FNum",&v)?0:(int)uint_value(&v);}
static void key(char*out,int i,const char*s){snprintf(out,5,"F%d%s",i,s);}
static int mode_key(char*out,int i){key(out,i,"md");KeyInfo x;if(!info(out,&x))return 0;key(out,i,"Md");return info(out,&x);}
static int write_mode(int i,uint8_t mode){char k[5];if(!mode_key(k,i))return write_key(k,&mode,1);Value v={0};if(read_key("FS! ",&v))return -3;uint16_t bits=(uint16_t)uint_value(&v);if(mode)bits|=1u<<i;else bits&=~(1u<<i);uint8_t b[2]={bits>>8,bits&255};return write_key("FS! ",b,2);}
static int read_mode(int i){char k[5];Value v={0};if(!mode_key(k,i))return read_key(k,&v)?0:(int)uint_value(&v);if(read_key("FS! ",&v))return 0;return (uint_value(&v)&(1u<<i))?1:0;}
static int encode_write_rpm(int i,float rpm){char k[5];key(k,i,"Tg");KeyInfo x={0};int e=info(k,&x);if(e)return e;if(x.type==fourcc("flt "))return write_key(k,&rpm,4);if(x.type==fourcc("fpe2")){uint16_t n=(uint16_t)(rpm*4);uint8_t b[2]={n>>8,n&255};return write_key(k,b,2);}return -4;}
static float read_rpm(int i,const char*s){char k[5];key(k,i,s);Value v={0};return read_key(k,&v)?0:rpm_value(&v);}
static int make_manual(int i){int e=write_mode(i,1);if(!e)return 0;KeyInfo x;if(info("Ftst",&x))return e;uint8_t one=1;if(write_key("Ftst",&one,1))return e;for(int n=0;n<100;n++){usleep(100000);if(!write_mode(i,1))return 0;}return e;}
static int set_all(float requested){if(geteuid()!=0){fprintf(stderr,"需要管理员权限\n");return 77;}int n=fan_count();if(n<1)return 2;for(int i=0;i<n;i++){float lo=read_rpm(i,"Mn"),hi=read_rpm(i,"Mx");if(hi<=lo)continue;float rpm=fmaxf(lo,fminf(hi,requested));int e=make_manual(i);if(e){fprintf(stderr,"风扇 %d 无法进入手动模式: 0x%x\n",i,e);return 3;}e=encode_write_rpm(i,rpm);if(e){write_mode(i,0);return 4;}}return 0;}
static int auto_all(void){if(geteuid()!=0)return 77;int n=fan_count();for(int i=0;i<n;i++)write_mode(i,0);uint8_t zero=0;KeyInfo x;if(!info("Ftst",&x))write_key("Ftst",&zero,1);return 0;}
static int list(void){int n=fan_count();printf("{\"fans\":[");for(int i=0;i<n;i++){if(i)putchar(',');printf("{\"id\":%d,\"actual\":%.0f,\"target\":%.0f,\"min\":%.0f,\"max\":%.0f,\"mode\":%d}",i,read_rpm(i,"Ac"),read_rpm(i,"Tg"),read_rpm(i,"Mn"),read_rpm(i,"Mx"),read_mode(i));}printf("]}\n");return n?0:2;}
static int send_cmd(const char*path,const char*cmd){int s=socket(AF_UNIX,SOCK_STREAM,0);struct sockaddr_un a={0};a.sun_family=AF_UNIX;strncpy(a.sun_path,path,sizeof(a.sun_path)-1);if(connect(s,(void*)&a,sizeof(a))){perror("辅助服务未连接");return 5;}write(s,cmd,strlen(cmd));write(s,"\n",1);char b[256]={0};ssize_t n=read(s,b,sizeof(b)-1);close(s);if(n>0)fwrite(b,1,n,stdout);return strncmp(b,"OK",2)?6:0;}
static int serve(const char*path,uid_t owner){
  if(geteuid()!=0)return 77;unlink(path);int s=socket(AF_UNIX,SOCK_STREAM,0);struct sockaddr_un a={0};a.sun_family=AF_UNIX;strncpy(a.sun_path,path,sizeof(a.sun_path)-1);if(bind(s,(void*)&a,sizeof(a))||listen(s,8))return 7;chown(path,owner,(gid_t)-1);chmod(path,0600);
  time_t last=time(NULL);int controlled=0;
  for(;;){fd_set f;FD_ZERO(&f);FD_SET(s,&f);struct timeval tv={1,0};int ready=select(s+1,&f,0,0,&tv);if(ready>0){int c=accept(s,0,0);char b[128]={0};ssize_t n=read(c,b,sizeof(b)-1);int ok=0;if(n>0&&sscanf(b,"SET %f",&(float){0})==1){float rpm=0;sscanf(b,"SET %f",&rpm);ok=set_all(rpm);controlled=!ok;}else if(!strncmp(b,"AUTO",4)){ok=auto_all();controlled=0;}else if(!strncmp(b,"PING",4)){ok=0;}else if(!strncmp(b,"QUIT",4)){auto_all();write(c,"OK\n",3);close(c);break;}else ok=64;last=time(NULL);dprintf(c,ok?"ERR %d\n":"OK\n",ok);close(c);}if(controlled&&time(NULL)-last>15){auto_all();controlled=0;} }
  close(s);unlink(path);return 0;
}
int main(int argc,char**argv){
  if(argc>3&&!strcmp(argv[1],"send"))return send_cmd(argv[2],argv[3]);
  int e=open_smc();if(e){fprintf(stderr,"无法连接 AppleSMC: 0x%x\n",e);return 1;}
  int r=argc<2?list():!strcmp(argv[1],"list")?list():!strcmp(argv[1],"auto")?auto_all():!strcmp(argv[1],"set")&&argc>2?set_all(strtof(argv[2],0)):!strcmp(argv[1],"serve")&&argc>3?serve(argv[2],(uid_t)strtoul(argv[3],0,10)):64;IOServiceClose(conn);return r;
}

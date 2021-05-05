
_date:     file format elf32-i386


Disassembly of section .text:

00000000 <dayofweek>:
static char *days[] = {"Sun", "Mon", "Tue", "Wed",
  "Thu", "Fri", "Sat"};

static int
dayofweek(int y, int m, int d)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	56                   	push   %esi
   4:	53                   	push   %ebx
   5:	89 c3                	mov    %eax,%ebx
  return (d+=m<3?y--:y-2,23*m/9+d+4+y/4-y/100+y/400)%7;
   7:	83 fa 02             	cmp    $0x2,%edx
   a:	7e 6e                	jle    7a <dayofweek+0x7a>
   c:	8d 40 fe             	lea    -0x2(%eax),%eax
   f:	01 c1                	add    %eax,%ecx
  11:	6b f2 17             	imul   $0x17,%edx,%esi
  14:	ba 39 8e e3 38       	mov    $0x38e38e39,%edx
  19:	89 f0                	mov    %esi,%eax
  1b:	f7 ea                	imul   %edx
  1d:	d1 fa                	sar    %edx
  1f:	c1 fe 1f             	sar    $0x1f,%esi
  22:	29 f2                	sub    %esi,%edx
  24:	8d 44 0a 04          	lea    0x4(%edx,%ecx,1),%eax
  28:	8d 4b 03             	lea    0x3(%ebx),%ecx
  2b:	85 db                	test   %ebx,%ebx
  2d:	0f 49 cb             	cmovns %ebx,%ecx
  30:	c1 f9 02             	sar    $0x2,%ecx
  33:	01 c1                	add    %eax,%ecx
  35:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  3a:	89 d8                	mov    %ebx,%eax
  3c:	f7 ea                	imul   %edx
  3e:	89 d0                	mov    %edx,%eax
  40:	c1 f8 05             	sar    $0x5,%eax
  43:	c1 fb 1f             	sar    $0x1f,%ebx
  46:	89 de                	mov    %ebx,%esi
  48:	29 c6                	sub    %eax,%esi
  4a:	01 f1                	add    %esi,%ecx
  4c:	c1 fa 07             	sar    $0x7,%edx
  4f:	29 da                	sub    %ebx,%edx
  51:	01 d1                	add    %edx,%ecx
  53:	ba 93 24 49 92       	mov    $0x92492493,%edx
  58:	89 c8                	mov    %ecx,%eax
  5a:	f7 ea                	imul   %edx
  5c:	8d 04 0a             	lea    (%edx,%ecx,1),%eax
  5f:	c1 f8 02             	sar    $0x2,%eax
  62:	89 ca                	mov    %ecx,%edx
  64:	c1 fa 1f             	sar    $0x1f,%edx
  67:	29 d0                	sub    %edx,%eax
  69:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
  70:	29 c2                	sub    %eax,%edx
  72:	29 d1                	sub    %edx,%ecx
  74:	89 c8                	mov    %ecx,%eax
}
  76:	5b                   	pop    %ebx
  77:	5e                   	pop    %esi
  78:	5d                   	pop    %ebp
  79:	c3                   	ret    
  return (d+=m<3?y--:y-2,23*m/9+d+4+y/4-y/100+y/400)%7;
  7a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  7d:	eb 90                	jmp    f <dayofweek+0xf>

0000007f <main>:

int
main(int argc, char *argv[])
{
  7f:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  83:	83 e4 f0             	and    $0xfffffff0,%esp
  86:	ff 71 fc             	pushl  -0x4(%ecx)
  89:	55                   	push   %ebp
  8a:	89 e5                	mov    %esp,%ebp
  8c:	57                   	push   %edi
  8d:	56                   	push   %esi
  8e:	53                   	push   %ebx
  8f:	51                   	push   %ecx
  90:	83 ec 54             	sub    $0x54,%esp
  int day;
  char *s;
  struct rtcdate r;

  if (date(&r)) {
  93:	8d 45 d0             	lea    -0x30(%ebp),%eax
  96:	50                   	push   %eax
  97:	e8 3c 04 00 00       	call   4d8 <date>
  9c:	83 c4 10             	add    $0x10,%esp
  9f:	85 c0                	test   %eax,%eax
  a1:	0f 85 d7 00 00 00    	jne    17e <main+0xff>
    printf(2,"Error: date call failed. %s at line %d\n",
        __FILE__, __LINE__);
    exit();
  }

  day = dayofweek(r.year, r.month, r.day);
  a7:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  aa:	8b 75 e0             	mov    -0x20(%ebp),%esi
  ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  b0:	89 d9                	mov    %ebx,%ecx
  b2:	89 f2                	mov    %esi,%edx
  b4:	89 f8                	mov    %edi,%eax
  b6:	e8 45 ff ff ff       	call   0 <dayofweek>
  bb:	89 45 b0             	mov    %eax,-0x50(%ebp)
  s = r.hour < 12 ? "AM" : "PM";
  be:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  c1:	83 f9 0b             	cmp    $0xb,%ecx
  c4:	0f 87 cc 00 00 00    	ja     196 <main+0x117>
  ca:	c7 45 c0 40 08 00 00 	movl   $0x840,-0x40(%ebp)

  r.hour %= 12;
  d1:	ba ab aa aa aa       	mov    $0xaaaaaaab,%edx
  d6:	89 c8                	mov    %ecx,%eax
  d8:	f7 e2                	mul    %edx
  da:	c1 ea 03             	shr    $0x3,%edx
  dd:	8d 14 52             	lea    (%edx,%edx,2),%edx
  e0:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
  e7:	29 c1                	sub    %eax,%ecx
  e9:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  if (r.hour == 0) r.hour = 12;
  ec:	85 c9                	test   %ecx,%ecx
  ee:	75 07                	jne    f7 <main+0x78>
  f0:	c7 45 d8 0c 00 00 00 	movl   $0xc,-0x28(%ebp)

  printf(1, "%s %s%d %s %d %s%d:%s%d:%s%d %s UTC\n", days[day], PAD(r.day), r.day,
  f7:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  fa:	83 f9 09             	cmp    $0x9,%ecx
  fd:	0f 87 9f 00 00 00    	ja     1a2 <main+0x123>
 103:	c7 45 bc 46 08 00 00 	movl   $0x846,-0x44(%ebp)
 10a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
 10d:	83 fa 09             	cmp    $0x9,%edx
 110:	0f 87 98 00 00 00    	ja     1ae <main+0x12f>
 116:	c7 45 b8 46 08 00 00 	movl   $0x846,-0x48(%ebp)
 11d:	8b 45 d8             	mov    -0x28(%ebp),%eax
 120:	83 f8 09             	cmp    $0x9,%eax
 123:	0f 87 91 00 00 00    	ja     1ba <main+0x13b>
 129:	c7 45 b4 46 08 00 00 	movl   $0x846,-0x4c(%ebp)
 130:	8b 34 b5 20 09 00 00 	mov    0x920(,%esi,4),%esi
 137:	89 75 c4             	mov    %esi,-0x3c(%ebp)
 13a:	83 fb 09             	cmp    $0x9,%ebx
 13d:	0f 87 83 00 00 00    	ja     1c6 <main+0x147>
 143:	be 46 08 00 00       	mov    $0x846,%esi
 148:	83 ec 08             	sub    $0x8,%esp
 14b:	ff 75 c0             	pushl  -0x40(%ebp)
 14e:	51                   	push   %ecx
 14f:	ff 75 bc             	pushl  -0x44(%ebp)
 152:	52                   	push   %edx
 153:	ff 75 b8             	pushl  -0x48(%ebp)
 156:	50                   	push   %eax
 157:	ff 75 b4             	pushl  -0x4c(%ebp)
 15a:	57                   	push   %edi
 15b:	ff 75 c4             	pushl  -0x3c(%ebp)
 15e:	53                   	push   %ebx
 15f:	56                   	push   %esi
 160:	8b 45 b0             	mov    -0x50(%ebp),%eax
 163:	ff 34 85 00 09 00 00 	pushl  0x900(,%eax,4)
 16a:	68 c8 08 00 00       	push   $0x8c8
 16f:	6a 01                	push   $0x1
 171:	e8 04 04 00 00       	call   57a <printf>
      months[r.month], r.year, PAD(r.hour), r.hour, PAD(r.minute), r.minute,
      PAD(r.second), r.second, s);

  exit();
 176:	83 c4 40             	add    $0x40,%esp
 179:	e8 b2 02 00 00       	call   430 <exit>
    printf(2,"Error: date call failed. %s at line %d\n",
 17e:	6a 1f                	push   $0x1f
 180:	68 48 08 00 00       	push   $0x848
 185:	68 a0 08 00 00       	push   $0x8a0
 18a:	6a 02                	push   $0x2
 18c:	e8 e9 03 00 00       	call   57a <printf>
    exit();
 191:	e8 9a 02 00 00       	call   430 <exit>
  s = r.hour < 12 ? "AM" : "PM";
 196:	c7 45 c0 43 08 00 00 	movl   $0x843,-0x40(%ebp)
 19d:	e9 2f ff ff ff       	jmp    d1 <main+0x52>
  printf(1, "%s %s%d %s %d %s%d:%s%d:%s%d %s UTC\n", days[day], PAD(r.day), r.day,
 1a2:	c7 45 bc 5a 09 00 00 	movl   $0x95a,-0x44(%ebp)
 1a9:	e9 5c ff ff ff       	jmp    10a <main+0x8b>
 1ae:	c7 45 b8 5a 09 00 00 	movl   $0x95a,-0x48(%ebp)
 1b5:	e9 63 ff ff ff       	jmp    11d <main+0x9e>
 1ba:	c7 45 b4 5a 09 00 00 	movl   $0x95a,-0x4c(%ebp)
 1c1:	e9 6a ff ff ff       	jmp    130 <main+0xb1>
 1c6:	be 5a 09 00 00       	mov    $0x95a,%esi
 1cb:	e9 78 ff ff ff       	jmp    148 <main+0xc9>

000001d0 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 1d0:	55                   	push   %ebp
 1d1:	89 e5                	mov    %esp,%ebp
 1d3:	53                   	push   %ebx
 1d4:	8b 45 08             	mov    0x8(%ebp),%eax
 1d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1da:	89 c2                	mov    %eax,%edx
 1dc:	0f b6 19             	movzbl (%ecx),%ebx
 1df:	88 1a                	mov    %bl,(%edx)
 1e1:	8d 52 01             	lea    0x1(%edx),%edx
 1e4:	8d 49 01             	lea    0x1(%ecx),%ecx
 1e7:	84 db                	test   %bl,%bl
 1e9:	75 f1                	jne    1dc <strcpy+0xc>
    ;
  return os;
}
 1eb:	5b                   	pop    %ebx
 1ec:	5d                   	pop    %ebp
 1ed:	c3                   	ret    

000001ee <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1ee:	55                   	push   %ebp
 1ef:	89 e5                	mov    %esp,%ebp
 1f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
 1f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 1f7:	eb 06                	jmp    1ff <strcmp+0x11>
    p++, q++;
 1f9:	83 c1 01             	add    $0x1,%ecx
 1fc:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 1ff:	0f b6 01             	movzbl (%ecx),%eax
 202:	84 c0                	test   %al,%al
 204:	74 04                	je     20a <strcmp+0x1c>
 206:	3a 02                	cmp    (%edx),%al
 208:	74 ef                	je     1f9 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 20a:	0f b6 c0             	movzbl %al,%eax
 20d:	0f b6 12             	movzbl (%edx),%edx
 210:	29 d0                	sub    %edx,%eax
}
 212:	5d                   	pop    %ebp
 213:	c3                   	ret    

00000214 <strlen>:

uint
strlen(char *s)
{
 214:	55                   	push   %ebp
 215:	89 e5                	mov    %esp,%ebp
 217:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 21a:	ba 00 00 00 00       	mov    $0x0,%edx
 21f:	eb 03                	jmp    224 <strlen+0x10>
 221:	83 c2 01             	add    $0x1,%edx
 224:	89 d0                	mov    %edx,%eax
 226:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 22a:	75 f5                	jne    221 <strlen+0xd>
    ;
  return n;
}
 22c:	5d                   	pop    %ebp
 22d:	c3                   	ret    

0000022e <memset>:

void*
memset(void *dst, int c, uint n)
{
 22e:	55                   	push   %ebp
 22f:	89 e5                	mov    %esp,%ebp
 231:	57                   	push   %edi
 232:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 235:	89 d7                	mov    %edx,%edi
 237:	8b 4d 10             	mov    0x10(%ebp),%ecx
 23a:	8b 45 0c             	mov    0xc(%ebp),%eax
 23d:	fc                   	cld    
 23e:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 240:	89 d0                	mov    %edx,%eax
 242:	5f                   	pop    %edi
 243:	5d                   	pop    %ebp
 244:	c3                   	ret    

00000245 <strchr>:

char*
strchr(const char *s, char c)
{
 245:	55                   	push   %ebp
 246:	89 e5                	mov    %esp,%ebp
 248:	8b 45 08             	mov    0x8(%ebp),%eax
 24b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 24f:	0f b6 10             	movzbl (%eax),%edx
 252:	84 d2                	test   %dl,%dl
 254:	74 09                	je     25f <strchr+0x1a>
    if(*s == c)
 256:	38 ca                	cmp    %cl,%dl
 258:	74 0a                	je     264 <strchr+0x1f>
  for(; *s; s++)
 25a:	83 c0 01             	add    $0x1,%eax
 25d:	eb f0                	jmp    24f <strchr+0xa>
      return (char*)s;
  return 0;
 25f:	b8 00 00 00 00       	mov    $0x0,%eax
}
 264:	5d                   	pop    %ebp
 265:	c3                   	ret    

00000266 <gets>:

char*
gets(char *buf, int max)
{
 266:	55                   	push   %ebp
 267:	89 e5                	mov    %esp,%ebp
 269:	57                   	push   %edi
 26a:	56                   	push   %esi
 26b:	53                   	push   %ebx
 26c:	83 ec 1c             	sub    $0x1c,%esp
 26f:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 272:	bb 00 00 00 00       	mov    $0x0,%ebx
 277:	8d 73 01             	lea    0x1(%ebx),%esi
 27a:	3b 75 0c             	cmp    0xc(%ebp),%esi
 27d:	7d 2e                	jge    2ad <gets+0x47>
    cc = read(0, &c, 1);
 27f:	83 ec 04             	sub    $0x4,%esp
 282:	6a 01                	push   $0x1
 284:	8d 45 e7             	lea    -0x19(%ebp),%eax
 287:	50                   	push   %eax
 288:	6a 00                	push   $0x0
 28a:	e8 b9 01 00 00       	call   448 <read>
    if(cc < 1)
 28f:	83 c4 10             	add    $0x10,%esp
 292:	85 c0                	test   %eax,%eax
 294:	7e 17                	jle    2ad <gets+0x47>
      break;
    buf[i++] = c;
 296:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 29a:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 29d:	3c 0a                	cmp    $0xa,%al
 29f:	0f 94 c2             	sete   %dl
 2a2:	3c 0d                	cmp    $0xd,%al
 2a4:	0f 94 c0             	sete   %al
    buf[i++] = c;
 2a7:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 2a9:	08 c2                	or     %al,%dl
 2ab:	74 ca                	je     277 <gets+0x11>
      break;
  }
  buf[i] = '\0';
 2ad:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 2b1:	89 f8                	mov    %edi,%eax
 2b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
 2b6:	5b                   	pop    %ebx
 2b7:	5e                   	pop    %esi
 2b8:	5f                   	pop    %edi
 2b9:	5d                   	pop    %ebp
 2ba:	c3                   	ret    

000002bb <stat>:

int
stat(char *n, struct stat *st)
{
 2bb:	55                   	push   %ebp
 2bc:	89 e5                	mov    %esp,%ebp
 2be:	56                   	push   %esi
 2bf:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2c0:	83 ec 08             	sub    $0x8,%esp
 2c3:	6a 00                	push   $0x0
 2c5:	ff 75 08             	pushl  0x8(%ebp)
 2c8:	e8 a3 01 00 00       	call   470 <open>
  if(fd < 0)
 2cd:	83 c4 10             	add    $0x10,%esp
 2d0:	85 c0                	test   %eax,%eax
 2d2:	78 24                	js     2f8 <stat+0x3d>
 2d4:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 2d6:	83 ec 08             	sub    $0x8,%esp
 2d9:	ff 75 0c             	pushl  0xc(%ebp)
 2dc:	50                   	push   %eax
 2dd:	e8 a6 01 00 00       	call   488 <fstat>
 2e2:	89 c6                	mov    %eax,%esi
  close(fd);
 2e4:	89 1c 24             	mov    %ebx,(%esp)
 2e7:	e8 6c 01 00 00       	call   458 <close>
  return r;
 2ec:	83 c4 10             	add    $0x10,%esp
}
 2ef:	89 f0                	mov    %esi,%eax
 2f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
 2f4:	5b                   	pop    %ebx
 2f5:	5e                   	pop    %esi
 2f6:	5d                   	pop    %ebp
 2f7:	c3                   	ret    
    return -1;
 2f8:	be ff ff ff ff       	mov    $0xffffffff,%esi
 2fd:	eb f0                	jmp    2ef <stat+0x34>

000002ff <atoi>:

#ifdef PDX_XV6
int
atoi(const char *s)
{
 2ff:	55                   	push   %ebp
 300:	89 e5                	mov    %esp,%ebp
 302:	57                   	push   %edi
 303:	56                   	push   %esi
 304:	53                   	push   %ebx
 305:	8b 55 08             	mov    0x8(%ebp),%edx
  int n, sign;

  n = 0;
  while (*s == ' ') s++;
 308:	eb 03                	jmp    30d <atoi+0xe>
 30a:	83 c2 01             	add    $0x1,%edx
 30d:	0f b6 02             	movzbl (%edx),%eax
 310:	3c 20                	cmp    $0x20,%al
 312:	74 f6                	je     30a <atoi+0xb>
  sign = (*s == '-') ? -1 : 1;
 314:	3c 2d                	cmp    $0x2d,%al
 316:	74 1d                	je     335 <atoi+0x36>
 318:	bf 01 00 00 00       	mov    $0x1,%edi
  if (*s == '+'  || *s == '-')
 31d:	3c 2b                	cmp    $0x2b,%al
 31f:	0f 94 c1             	sete   %cl
 322:	3c 2d                	cmp    $0x2d,%al
 324:	0f 94 c0             	sete   %al
 327:	08 c1                	or     %al,%cl
 329:	74 03                	je     32e <atoi+0x2f>
    s++;
 32b:	83 c2 01             	add    $0x1,%edx
  sign = (*s == '-') ? -1 : 1;
 32e:	b8 00 00 00 00       	mov    $0x0,%eax
 333:	eb 17                	jmp    34c <atoi+0x4d>
 335:	bf ff ff ff ff       	mov    $0xffffffff,%edi
 33a:	eb e1                	jmp    31d <atoi+0x1e>
  while('0' <= *s && *s <= '9')
    n = n*10 + *s++ - '0';
 33c:	8d 34 80             	lea    (%eax,%eax,4),%esi
 33f:	8d 1c 36             	lea    (%esi,%esi,1),%ebx
 342:	83 c2 01             	add    $0x1,%edx
 345:	0f be c9             	movsbl %cl,%ecx
 348:	8d 44 19 d0          	lea    -0x30(%ecx,%ebx,1),%eax
  while('0' <= *s && *s <= '9')
 34c:	0f b6 0a             	movzbl (%edx),%ecx
 34f:	8d 59 d0             	lea    -0x30(%ecx),%ebx
 352:	80 fb 09             	cmp    $0x9,%bl
 355:	76 e5                	jbe    33c <atoi+0x3d>
  return sign*n;
 357:	0f af c7             	imul   %edi,%eax
}
 35a:	5b                   	pop    %ebx
 35b:	5e                   	pop    %esi
 35c:	5f                   	pop    %edi
 35d:	5d                   	pop    %ebp
 35e:	c3                   	ret    

0000035f <atoo>:

int
atoo(const char *s)
{
 35f:	55                   	push   %ebp
 360:	89 e5                	mov    %esp,%ebp
 362:	57                   	push   %edi
 363:	56                   	push   %esi
 364:	53                   	push   %ebx
 365:	8b 55 08             	mov    0x8(%ebp),%edx
  int n, sign;

  n = 0;
  while (*s == ' ') s++;
 368:	eb 03                	jmp    36d <atoo+0xe>
 36a:	83 c2 01             	add    $0x1,%edx
 36d:	0f b6 0a             	movzbl (%edx),%ecx
 370:	80 f9 20             	cmp    $0x20,%cl
 373:	74 f5                	je     36a <atoo+0xb>
  sign = (*s == '-') ? -1 : 1;
 375:	80 f9 2d             	cmp    $0x2d,%cl
 378:	74 23                	je     39d <atoo+0x3e>
 37a:	bf 01 00 00 00       	mov    $0x1,%edi
  if (*s == '+'  || *s == '-')
 37f:	80 f9 2b             	cmp    $0x2b,%cl
 382:	0f 94 c0             	sete   %al
 385:	89 c6                	mov    %eax,%esi
 387:	80 f9 2d             	cmp    $0x2d,%cl
 38a:	0f 94 c0             	sete   %al
 38d:	89 f3                	mov    %esi,%ebx
 38f:	08 c3                	or     %al,%bl
 391:	74 03                	je     396 <atoo+0x37>
    s++;
 393:	83 c2 01             	add    $0x1,%edx
  sign = (*s == '-') ? -1 : 1;
 396:	b8 00 00 00 00       	mov    $0x0,%eax
 39b:	eb 11                	jmp    3ae <atoo+0x4f>
 39d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
 3a2:	eb db                	jmp    37f <atoo+0x20>
  while('0' <= *s && *s <= '7')
    n = n*8 + *s++ - '0';
 3a4:	83 c2 01             	add    $0x1,%edx
 3a7:	0f be c9             	movsbl %cl,%ecx
 3aa:	8d 44 c1 d0          	lea    -0x30(%ecx,%eax,8),%eax
  while('0' <= *s && *s <= '7')
 3ae:	0f b6 0a             	movzbl (%edx),%ecx
 3b1:	8d 59 d0             	lea    -0x30(%ecx),%ebx
 3b4:	80 fb 07             	cmp    $0x7,%bl
 3b7:	76 eb                	jbe    3a4 <atoo+0x45>
  return sign*n;
 3b9:	0f af c7             	imul   %edi,%eax
}
 3bc:	5b                   	pop    %ebx
 3bd:	5e                   	pop    %esi
 3be:	5f                   	pop    %edi
 3bf:	5d                   	pop    %ebp
 3c0:	c3                   	ret    

000003c1 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
 3c1:	55                   	push   %ebp
 3c2:	89 e5                	mov    %esp,%ebp
 3c4:	53                   	push   %ebx
 3c5:	8b 55 08             	mov    0x8(%ebp),%edx
 3c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
 3cb:	8b 45 10             	mov    0x10(%ebp),%eax
    while(n > 0 && *p && *p == *q)
 3ce:	eb 09                	jmp    3d9 <strncmp+0x18>
      n--, p++, q++;
 3d0:	83 e8 01             	sub    $0x1,%eax
 3d3:	83 c2 01             	add    $0x1,%edx
 3d6:	83 c1 01             	add    $0x1,%ecx
    while(n > 0 && *p && *p == *q)
 3d9:	85 c0                	test   %eax,%eax
 3db:	74 0b                	je     3e8 <strncmp+0x27>
 3dd:	0f b6 1a             	movzbl (%edx),%ebx
 3e0:	84 db                	test   %bl,%bl
 3e2:	74 04                	je     3e8 <strncmp+0x27>
 3e4:	3a 19                	cmp    (%ecx),%bl
 3e6:	74 e8                	je     3d0 <strncmp+0xf>
    if(n == 0)
 3e8:	85 c0                	test   %eax,%eax
 3ea:	74 0b                	je     3f7 <strncmp+0x36>
      return 0;
    return (uchar)*p - (uchar)*q;
 3ec:	0f b6 02             	movzbl (%edx),%eax
 3ef:	0f b6 11             	movzbl (%ecx),%edx
 3f2:	29 d0                	sub    %edx,%eax
}
 3f4:	5b                   	pop    %ebx
 3f5:	5d                   	pop    %ebp
 3f6:	c3                   	ret    
      return 0;
 3f7:	b8 00 00 00 00       	mov    $0x0,%eax
 3fc:	eb f6                	jmp    3f4 <strncmp+0x33>

000003fe <memmove>:
}
#endif // PDX_XV6

void*
memmove(void *vdst, void *vsrc, int n)
{
 3fe:	55                   	push   %ebp
 3ff:	89 e5                	mov    %esp,%ebp
 401:	56                   	push   %esi
 402:	53                   	push   %ebx
 403:	8b 45 08             	mov    0x8(%ebp),%eax
 406:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 409:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst, *src;

  dst = vdst;
 40c:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 40e:	eb 0d                	jmp    41d <memmove+0x1f>
    *dst++ = *src++;
 410:	0f b6 13             	movzbl (%ebx),%edx
 413:	88 11                	mov    %dl,(%ecx)
 415:	8d 5b 01             	lea    0x1(%ebx),%ebx
 418:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 41b:	89 f2                	mov    %esi,%edx
 41d:	8d 72 ff             	lea    -0x1(%edx),%esi
 420:	85 d2                	test   %edx,%edx
 422:	7f ec                	jg     410 <memmove+0x12>
  return vdst;
}
 424:	5b                   	pop    %ebx
 425:	5e                   	pop    %esi
 426:	5d                   	pop    %ebp
 427:	c3                   	ret    

00000428 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 428:	b8 01 00 00 00       	mov    $0x1,%eax
 42d:	cd 40                	int    $0x40
 42f:	c3                   	ret    

00000430 <exit>:
SYSCALL(exit)
 430:	b8 02 00 00 00       	mov    $0x2,%eax
 435:	cd 40                	int    $0x40
 437:	c3                   	ret    

00000438 <wait>:
SYSCALL(wait)
 438:	b8 03 00 00 00       	mov    $0x3,%eax
 43d:	cd 40                	int    $0x40
 43f:	c3                   	ret    

00000440 <pipe>:
SYSCALL(pipe)
 440:	b8 04 00 00 00       	mov    $0x4,%eax
 445:	cd 40                	int    $0x40
 447:	c3                   	ret    

00000448 <read>:
SYSCALL(read)
 448:	b8 05 00 00 00       	mov    $0x5,%eax
 44d:	cd 40                	int    $0x40
 44f:	c3                   	ret    

00000450 <write>:
SYSCALL(write)
 450:	b8 10 00 00 00       	mov    $0x10,%eax
 455:	cd 40                	int    $0x40
 457:	c3                   	ret    

00000458 <close>:
SYSCALL(close)
 458:	b8 15 00 00 00       	mov    $0x15,%eax
 45d:	cd 40                	int    $0x40
 45f:	c3                   	ret    

00000460 <kill>:
SYSCALL(kill)
 460:	b8 06 00 00 00       	mov    $0x6,%eax
 465:	cd 40                	int    $0x40
 467:	c3                   	ret    

00000468 <exec>:
SYSCALL(exec)
 468:	b8 07 00 00 00       	mov    $0x7,%eax
 46d:	cd 40                	int    $0x40
 46f:	c3                   	ret    

00000470 <open>:
SYSCALL(open)
 470:	b8 0f 00 00 00       	mov    $0xf,%eax
 475:	cd 40                	int    $0x40
 477:	c3                   	ret    

00000478 <mknod>:
SYSCALL(mknod)
 478:	b8 11 00 00 00       	mov    $0x11,%eax
 47d:	cd 40                	int    $0x40
 47f:	c3                   	ret    

00000480 <unlink>:
SYSCALL(unlink)
 480:	b8 12 00 00 00       	mov    $0x12,%eax
 485:	cd 40                	int    $0x40
 487:	c3                   	ret    

00000488 <fstat>:
SYSCALL(fstat)
 488:	b8 08 00 00 00       	mov    $0x8,%eax
 48d:	cd 40                	int    $0x40
 48f:	c3                   	ret    

00000490 <link>:
SYSCALL(link)
 490:	b8 13 00 00 00       	mov    $0x13,%eax
 495:	cd 40                	int    $0x40
 497:	c3                   	ret    

00000498 <mkdir>:
SYSCALL(mkdir)
 498:	b8 14 00 00 00       	mov    $0x14,%eax
 49d:	cd 40                	int    $0x40
 49f:	c3                   	ret    

000004a0 <chdir>:
SYSCALL(chdir)
 4a0:	b8 09 00 00 00       	mov    $0x9,%eax
 4a5:	cd 40                	int    $0x40
 4a7:	c3                   	ret    

000004a8 <dup>:
SYSCALL(dup)
 4a8:	b8 0a 00 00 00       	mov    $0xa,%eax
 4ad:	cd 40                	int    $0x40
 4af:	c3                   	ret    

000004b0 <getpid>:
SYSCALL(getpid)
 4b0:	b8 0b 00 00 00       	mov    $0xb,%eax
 4b5:	cd 40                	int    $0x40
 4b7:	c3                   	ret    

000004b8 <sbrk>:
SYSCALL(sbrk)
 4b8:	b8 0c 00 00 00       	mov    $0xc,%eax
 4bd:	cd 40                	int    $0x40
 4bf:	c3                   	ret    

000004c0 <sleep>:
SYSCALL(sleep)
 4c0:	b8 0d 00 00 00       	mov    $0xd,%eax
 4c5:	cd 40                	int    $0x40
 4c7:	c3                   	ret    

000004c8 <uptime>:
SYSCALL(uptime)
 4c8:	b8 0e 00 00 00       	mov    $0xe,%eax
 4cd:	cd 40                	int    $0x40
 4cf:	c3                   	ret    

000004d0 <halt>:
SYSCALL(halt)
 4d0:	b8 16 00 00 00       	mov    $0x16,%eax
 4d5:	cd 40                	int    $0x40
 4d7:	c3                   	ret    

000004d8 <date>:
SYSCALL(date)
 4d8:	b8 17 00 00 00       	mov    $0x17,%eax
 4dd:	cd 40                	int    $0x40
 4df:	c3                   	ret    

000004e0 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 4e0:	55                   	push   %ebp
 4e1:	89 e5                	mov    %esp,%ebp
 4e3:	83 ec 1c             	sub    $0x1c,%esp
 4e6:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 4e9:	6a 01                	push   $0x1
 4eb:	8d 55 f4             	lea    -0xc(%ebp),%edx
 4ee:	52                   	push   %edx
 4ef:	50                   	push   %eax
 4f0:	e8 5b ff ff ff       	call   450 <write>
}
 4f5:	83 c4 10             	add    $0x10,%esp
 4f8:	c9                   	leave  
 4f9:	c3                   	ret    

000004fa <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4fa:	55                   	push   %ebp
 4fb:	89 e5                	mov    %esp,%ebp
 4fd:	57                   	push   %edi
 4fe:	56                   	push   %esi
 4ff:	53                   	push   %ebx
 500:	83 ec 2c             	sub    $0x2c,%esp
 503:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 505:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 509:	0f 95 c3             	setne  %bl
 50c:	89 d0                	mov    %edx,%eax
 50e:	c1 e8 1f             	shr    $0x1f,%eax
 511:	84 c3                	test   %al,%bl
 513:	74 10                	je     525 <printint+0x2b>
    neg = 1;
    x = -xx;
 515:	f7 da                	neg    %edx
    neg = 1;
 517:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 51e:	be 00 00 00 00       	mov    $0x0,%esi
 523:	eb 0b                	jmp    530 <printint+0x36>
  neg = 0;
 525:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 52c:	eb f0                	jmp    51e <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 52e:	89 c6                	mov    %eax,%esi
 530:	89 d0                	mov    %edx,%eax
 532:	ba 00 00 00 00       	mov    $0x0,%edx
 537:	f7 f1                	div    %ecx
 539:	89 c3                	mov    %eax,%ebx
 53b:	8d 46 01             	lea    0x1(%esi),%eax
 53e:	0f b6 92 5c 09 00 00 	movzbl 0x95c(%edx),%edx
 545:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 549:	89 da                	mov    %ebx,%edx
 54b:	85 db                	test   %ebx,%ebx
 54d:	75 df                	jne    52e <printint+0x34>
 54f:	89 c3                	mov    %eax,%ebx
  if(neg)
 551:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 555:	74 16                	je     56d <printint+0x73>
    buf[i++] = '-';
 557:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 55c:	8d 5e 02             	lea    0x2(%esi),%ebx
 55f:	eb 0c                	jmp    56d <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 561:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 566:	89 f8                	mov    %edi,%eax
 568:	e8 73 ff ff ff       	call   4e0 <putc>
  while(--i >= 0)
 56d:	83 eb 01             	sub    $0x1,%ebx
 570:	79 ef                	jns    561 <printint+0x67>
}
 572:	83 c4 2c             	add    $0x2c,%esp
 575:	5b                   	pop    %ebx
 576:	5e                   	pop    %esi
 577:	5f                   	pop    %edi
 578:	5d                   	pop    %ebp
 579:	c3                   	ret    

0000057a <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 57a:	55                   	push   %ebp
 57b:	89 e5                	mov    %esp,%ebp
 57d:	57                   	push   %edi
 57e:	56                   	push   %esi
 57f:	53                   	push   %ebx
 580:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 583:	8d 45 10             	lea    0x10(%ebp),%eax
 586:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 589:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 58e:	bb 00 00 00 00       	mov    $0x0,%ebx
 593:	eb 14                	jmp    5a9 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 595:	89 fa                	mov    %edi,%edx
 597:	8b 45 08             	mov    0x8(%ebp),%eax
 59a:	e8 41 ff ff ff       	call   4e0 <putc>
 59f:	eb 05                	jmp    5a6 <printf+0x2c>
      }
    } else if(state == '%'){
 5a1:	83 fe 25             	cmp    $0x25,%esi
 5a4:	74 25                	je     5cb <printf+0x51>
  for(i = 0; fmt[i]; i++){
 5a6:	83 c3 01             	add    $0x1,%ebx
 5a9:	8b 45 0c             	mov    0xc(%ebp),%eax
 5ac:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 5b0:	84 c0                	test   %al,%al
 5b2:	0f 84 23 01 00 00    	je     6db <printf+0x161>
    c = fmt[i] & 0xff;
 5b8:	0f be f8             	movsbl %al,%edi
 5bb:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 5be:	85 f6                	test   %esi,%esi
 5c0:	75 df                	jne    5a1 <printf+0x27>
      if(c == '%'){
 5c2:	83 f8 25             	cmp    $0x25,%eax
 5c5:	75 ce                	jne    595 <printf+0x1b>
        state = '%';
 5c7:	89 c6                	mov    %eax,%esi
 5c9:	eb db                	jmp    5a6 <printf+0x2c>
      if(c == 'd'){
 5cb:	83 f8 64             	cmp    $0x64,%eax
 5ce:	74 49                	je     619 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 5d0:	83 f8 78             	cmp    $0x78,%eax
 5d3:	0f 94 c1             	sete   %cl
 5d6:	83 f8 70             	cmp    $0x70,%eax
 5d9:	0f 94 c2             	sete   %dl
 5dc:	08 d1                	or     %dl,%cl
 5de:	75 63                	jne    643 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 5e0:	83 f8 73             	cmp    $0x73,%eax
 5e3:	0f 84 84 00 00 00    	je     66d <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5e9:	83 f8 63             	cmp    $0x63,%eax
 5ec:	0f 84 b7 00 00 00    	je     6a9 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 5f2:	83 f8 25             	cmp    $0x25,%eax
 5f5:	0f 84 cc 00 00 00    	je     6c7 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5fb:	ba 25 00 00 00       	mov    $0x25,%edx
 600:	8b 45 08             	mov    0x8(%ebp),%eax
 603:	e8 d8 fe ff ff       	call   4e0 <putc>
        putc(fd, c);
 608:	89 fa                	mov    %edi,%edx
 60a:	8b 45 08             	mov    0x8(%ebp),%eax
 60d:	e8 ce fe ff ff       	call   4e0 <putc>
      }
      state = 0;
 612:	be 00 00 00 00       	mov    $0x0,%esi
 617:	eb 8d                	jmp    5a6 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 619:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 61c:	8b 17                	mov    (%edi),%edx
 61e:	83 ec 0c             	sub    $0xc,%esp
 621:	6a 01                	push   $0x1
 623:	b9 0a 00 00 00       	mov    $0xa,%ecx
 628:	8b 45 08             	mov    0x8(%ebp),%eax
 62b:	e8 ca fe ff ff       	call   4fa <printint>
        ap++;
 630:	83 c7 04             	add    $0x4,%edi
 633:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 636:	83 c4 10             	add    $0x10,%esp
      state = 0;
 639:	be 00 00 00 00       	mov    $0x0,%esi
 63e:	e9 63 ff ff ff       	jmp    5a6 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 643:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 646:	8b 17                	mov    (%edi),%edx
 648:	83 ec 0c             	sub    $0xc,%esp
 64b:	6a 00                	push   $0x0
 64d:	b9 10 00 00 00       	mov    $0x10,%ecx
 652:	8b 45 08             	mov    0x8(%ebp),%eax
 655:	e8 a0 fe ff ff       	call   4fa <printint>
        ap++;
 65a:	83 c7 04             	add    $0x4,%edi
 65d:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 660:	83 c4 10             	add    $0x10,%esp
      state = 0;
 663:	be 00 00 00 00       	mov    $0x0,%esi
 668:	e9 39 ff ff ff       	jmp    5a6 <printf+0x2c>
        s = (char*)*ap;
 66d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 670:	8b 30                	mov    (%eax),%esi
        ap++;
 672:	83 c0 04             	add    $0x4,%eax
 675:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 678:	85 f6                	test   %esi,%esi
 67a:	75 28                	jne    6a4 <printf+0x12a>
          s = "(null)";
 67c:	be 54 09 00 00       	mov    $0x954,%esi
 681:	8b 7d 08             	mov    0x8(%ebp),%edi
 684:	eb 0d                	jmp    693 <printf+0x119>
          putc(fd, *s);
 686:	0f be d2             	movsbl %dl,%edx
 689:	89 f8                	mov    %edi,%eax
 68b:	e8 50 fe ff ff       	call   4e0 <putc>
          s++;
 690:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 693:	0f b6 16             	movzbl (%esi),%edx
 696:	84 d2                	test   %dl,%dl
 698:	75 ec                	jne    686 <printf+0x10c>
      state = 0;
 69a:	be 00 00 00 00       	mov    $0x0,%esi
 69f:	e9 02 ff ff ff       	jmp    5a6 <printf+0x2c>
 6a4:	8b 7d 08             	mov    0x8(%ebp),%edi
 6a7:	eb ea                	jmp    693 <printf+0x119>
        putc(fd, *ap);
 6a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 6ac:	0f be 17             	movsbl (%edi),%edx
 6af:	8b 45 08             	mov    0x8(%ebp),%eax
 6b2:	e8 29 fe ff ff       	call   4e0 <putc>
        ap++;
 6b7:	83 c7 04             	add    $0x4,%edi
 6ba:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 6bd:	be 00 00 00 00       	mov    $0x0,%esi
 6c2:	e9 df fe ff ff       	jmp    5a6 <printf+0x2c>
        putc(fd, c);
 6c7:	89 fa                	mov    %edi,%edx
 6c9:	8b 45 08             	mov    0x8(%ebp),%eax
 6cc:	e8 0f fe ff ff       	call   4e0 <putc>
      state = 0;
 6d1:	be 00 00 00 00       	mov    $0x0,%esi
 6d6:	e9 cb fe ff ff       	jmp    5a6 <printf+0x2c>
    }
  }
}
 6db:	8d 65 f4             	lea    -0xc(%ebp),%esp
 6de:	5b                   	pop    %ebx
 6df:	5e                   	pop    %esi
 6e0:	5f                   	pop    %edi
 6e1:	5d                   	pop    %ebp
 6e2:	c3                   	ret    

000006e3 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6e3:	55                   	push   %ebp
 6e4:	89 e5                	mov    %esp,%ebp
 6e6:	57                   	push   %edi
 6e7:	56                   	push   %esi
 6e8:	53                   	push   %ebx
 6e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6ec:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6ef:	a1 88 0c 00 00       	mov    0xc88,%eax
 6f4:	eb 02                	jmp    6f8 <free+0x15>
 6f6:	89 d0                	mov    %edx,%eax
 6f8:	39 c8                	cmp    %ecx,%eax
 6fa:	73 04                	jae    700 <free+0x1d>
 6fc:	39 08                	cmp    %ecx,(%eax)
 6fe:	77 12                	ja     712 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 700:	8b 10                	mov    (%eax),%edx
 702:	39 c2                	cmp    %eax,%edx
 704:	77 f0                	ja     6f6 <free+0x13>
 706:	39 c8                	cmp    %ecx,%eax
 708:	72 08                	jb     712 <free+0x2f>
 70a:	39 ca                	cmp    %ecx,%edx
 70c:	77 04                	ja     712 <free+0x2f>
 70e:	89 d0                	mov    %edx,%eax
 710:	eb e6                	jmp    6f8 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 712:	8b 73 fc             	mov    -0x4(%ebx),%esi
 715:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 718:	8b 10                	mov    (%eax),%edx
 71a:	39 d7                	cmp    %edx,%edi
 71c:	74 19                	je     737 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 71e:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 721:	8b 50 04             	mov    0x4(%eax),%edx
 724:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 727:	39 ce                	cmp    %ecx,%esi
 729:	74 1b                	je     746 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 72b:	89 08                	mov    %ecx,(%eax)
  freep = p;
 72d:	a3 88 0c 00 00       	mov    %eax,0xc88
}
 732:	5b                   	pop    %ebx
 733:	5e                   	pop    %esi
 734:	5f                   	pop    %edi
 735:	5d                   	pop    %ebp
 736:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 737:	03 72 04             	add    0x4(%edx),%esi
 73a:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 73d:	8b 10                	mov    (%eax),%edx
 73f:	8b 12                	mov    (%edx),%edx
 741:	89 53 f8             	mov    %edx,-0x8(%ebx)
 744:	eb db                	jmp    721 <free+0x3e>
    p->s.size += bp->s.size;
 746:	03 53 fc             	add    -0x4(%ebx),%edx
 749:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 74c:	8b 53 f8             	mov    -0x8(%ebx),%edx
 74f:	89 10                	mov    %edx,(%eax)
 751:	eb da                	jmp    72d <free+0x4a>

00000753 <morecore>:

static Header*
morecore(uint nu)
{
 753:	55                   	push   %ebp
 754:	89 e5                	mov    %esp,%ebp
 756:	53                   	push   %ebx
 757:	83 ec 04             	sub    $0x4,%esp
 75a:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 75c:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 761:	77 05                	ja     768 <morecore+0x15>
    nu = 4096;
 763:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 768:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 76f:	83 ec 0c             	sub    $0xc,%esp
 772:	50                   	push   %eax
 773:	e8 40 fd ff ff       	call   4b8 <sbrk>
  if(p == (char*)-1)
 778:	83 c4 10             	add    $0x10,%esp
 77b:	83 f8 ff             	cmp    $0xffffffff,%eax
 77e:	74 1c                	je     79c <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 780:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 783:	83 c0 08             	add    $0x8,%eax
 786:	83 ec 0c             	sub    $0xc,%esp
 789:	50                   	push   %eax
 78a:	e8 54 ff ff ff       	call   6e3 <free>
  return freep;
 78f:	a1 88 0c 00 00       	mov    0xc88,%eax
 794:	83 c4 10             	add    $0x10,%esp
}
 797:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 79a:	c9                   	leave  
 79b:	c3                   	ret    
    return 0;
 79c:	b8 00 00 00 00       	mov    $0x0,%eax
 7a1:	eb f4                	jmp    797 <morecore+0x44>

000007a3 <malloc>:

void*
malloc(uint nbytes)
{
 7a3:	55                   	push   %ebp
 7a4:	89 e5                	mov    %esp,%ebp
 7a6:	53                   	push   %ebx
 7a7:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7aa:	8b 45 08             	mov    0x8(%ebp),%eax
 7ad:	8d 58 07             	lea    0x7(%eax),%ebx
 7b0:	c1 eb 03             	shr    $0x3,%ebx
 7b3:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 7b6:	8b 0d 88 0c 00 00    	mov    0xc88,%ecx
 7bc:	85 c9                	test   %ecx,%ecx
 7be:	74 04                	je     7c4 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7c0:	8b 01                	mov    (%ecx),%eax
 7c2:	eb 4d                	jmp    811 <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 7c4:	c7 05 88 0c 00 00 8c 	movl   $0xc8c,0xc88
 7cb:	0c 00 00 
 7ce:	c7 05 8c 0c 00 00 8c 	movl   $0xc8c,0xc8c
 7d5:	0c 00 00 
    base.s.size = 0;
 7d8:	c7 05 90 0c 00 00 00 	movl   $0x0,0xc90
 7df:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 7e2:	b9 8c 0c 00 00       	mov    $0xc8c,%ecx
 7e7:	eb d7                	jmp    7c0 <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 7e9:	39 da                	cmp    %ebx,%edx
 7eb:	74 1a                	je     807 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 7ed:	29 da                	sub    %ebx,%edx
 7ef:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7f2:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 7f5:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 7f8:	89 0d 88 0c 00 00    	mov    %ecx,0xc88
      return (void*)(p + 1);
 7fe:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 801:	83 c4 04             	add    $0x4,%esp
 804:	5b                   	pop    %ebx
 805:	5d                   	pop    %ebp
 806:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 807:	8b 10                	mov    (%eax),%edx
 809:	89 11                	mov    %edx,(%ecx)
 80b:	eb eb                	jmp    7f8 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 80d:	89 c1                	mov    %eax,%ecx
 80f:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 811:	8b 50 04             	mov    0x4(%eax),%edx
 814:	39 da                	cmp    %ebx,%edx
 816:	73 d1                	jae    7e9 <malloc+0x46>
    if(p == freep)
 818:	39 05 88 0c 00 00    	cmp    %eax,0xc88
 81e:	75 ed                	jne    80d <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 820:	89 d8                	mov    %ebx,%eax
 822:	e8 2c ff ff ff       	call   753 <morecore>
 827:	85 c0                	test   %eax,%eax
 829:	75 e2                	jne    80d <malloc+0x6a>
        return 0;
 82b:	b8 00 00 00 00       	mov    $0x0,%eax
 830:	eb cf                	jmp    801 <malloc+0x5e>

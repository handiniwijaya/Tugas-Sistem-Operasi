
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 80 10 00       	mov    $0x108000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 20 c6 10 80       	mov    $0x8010c620,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 98 2a 10 80       	mov    $0x80102a98,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	57                   	push   %edi
80100038:	56                   	push   %esi
80100039:	53                   	push   %ebx
8010003a:	83 ec 18             	sub    $0x18,%esp
8010003d:	89 c6                	mov    %eax,%esi
8010003f:	89 d7                	mov    %edx,%edi
  struct buf *b;

  acquire(&bcache.lock);
80100041:	68 20 c6 10 80       	push   $0x8010c620
80100046:	e8 2f 3c 00 00       	call   80103c7a <acquire>

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010004b:	8b 1d 70 0d 11 80    	mov    0x80110d70,%ebx
80100051:	83 c4 10             	add    $0x10,%esp
80100054:	eb 03                	jmp    80100059 <bget+0x25>
80100056:	8b 5b 54             	mov    0x54(%ebx),%ebx
80100059:	81 fb 1c 0d 11 80    	cmp    $0x80110d1c,%ebx
8010005f:	74 30                	je     80100091 <bget+0x5d>
    if(b->dev == dev && b->blockno == blockno){
80100061:	39 73 04             	cmp    %esi,0x4(%ebx)
80100064:	75 f0                	jne    80100056 <bget+0x22>
80100066:	39 7b 08             	cmp    %edi,0x8(%ebx)
80100069:	75 eb                	jne    80100056 <bget+0x22>
      b->refcnt++;
8010006b:	8b 43 4c             	mov    0x4c(%ebx),%eax
8010006e:	83 c0 01             	add    $0x1,%eax
80100071:	89 43 4c             	mov    %eax,0x4c(%ebx)
      release(&bcache.lock);
80100074:	83 ec 0c             	sub    $0xc,%esp
80100077:	68 20 c6 10 80       	push   $0x8010c620
8010007c:	e8 5e 3c 00 00       	call   80103cdf <release>
      acquiresleep(&b->lock);
80100081:	8d 43 0c             	lea    0xc(%ebx),%eax
80100084:	89 04 24             	mov    %eax,(%esp)
80100087:	e8 01 3a 00 00       	call   80103a8d <acquiresleep>
      return b;
8010008c:	83 c4 10             	add    $0x10,%esp
8010008f:	eb 4c                	jmp    801000dd <bget+0xa9>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100091:	8b 1d 6c 0d 11 80    	mov    0x80110d6c,%ebx
80100097:	eb 03                	jmp    8010009c <bget+0x68>
80100099:	8b 5b 50             	mov    0x50(%ebx),%ebx
8010009c:	81 fb 1c 0d 11 80    	cmp    $0x80110d1c,%ebx
801000a2:	74 43                	je     801000e7 <bget+0xb3>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
801000a4:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
801000a8:	75 ef                	jne    80100099 <bget+0x65>
801000aa:	f6 03 04             	testb  $0x4,(%ebx)
801000ad:	75 ea                	jne    80100099 <bget+0x65>
      b->dev = dev;
801000af:	89 73 04             	mov    %esi,0x4(%ebx)
      b->blockno = blockno;
801000b2:	89 7b 08             	mov    %edi,0x8(%ebx)
      b->flags = 0;
801000b5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
      b->refcnt = 1;
801000bb:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
      release(&bcache.lock);
801000c2:	83 ec 0c             	sub    $0xc,%esp
801000c5:	68 20 c6 10 80       	push   $0x8010c620
801000ca:	e8 10 3c 00 00       	call   80103cdf <release>
      acquiresleep(&b->lock);
801000cf:	8d 43 0c             	lea    0xc(%ebx),%eax
801000d2:	89 04 24             	mov    %eax,(%esp)
801000d5:	e8 b3 39 00 00       	call   80103a8d <acquiresleep>
      return b;
801000da:	83 c4 10             	add    $0x10,%esp
    }
  }
  panic("bget: no buffers");
}
801000dd:	89 d8                	mov    %ebx,%eax
801000df:	8d 65 f4             	lea    -0xc(%ebp),%esp
801000e2:	5b                   	pop    %ebx
801000e3:	5e                   	pop    %esi
801000e4:	5f                   	pop    %edi
801000e5:	5d                   	pop    %ebp
801000e6:	c3                   	ret    
  panic("bget: no buffers");
801000e7:	83 ec 0c             	sub    $0xc,%esp
801000ea:	68 e0 64 10 80       	push   $0x801064e0
801000ef:	e8 54 02 00 00       	call   80100348 <panic>

801000f4 <binit>:
{
801000f4:	55                   	push   %ebp
801000f5:	89 e5                	mov    %esp,%ebp
801000f7:	53                   	push   %ebx
801000f8:	83 ec 0c             	sub    $0xc,%esp
  initlock(&bcache.lock, "bcache");
801000fb:	68 f1 64 10 80       	push   $0x801064f1
80100100:	68 20 c6 10 80       	push   $0x8010c620
80100105:	e8 34 3a 00 00       	call   80103b3e <initlock>
  bcache.head.prev = &bcache.head;
8010010a:	c7 05 6c 0d 11 80 1c 	movl   $0x80110d1c,0x80110d6c
80100111:	0d 11 80 
  bcache.head.next = &bcache.head;
80100114:	c7 05 70 0d 11 80 1c 	movl   $0x80110d1c,0x80110d70
8010011b:	0d 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010011e:	83 c4 10             	add    $0x10,%esp
80100121:	bb 54 c6 10 80       	mov    $0x8010c654,%ebx
80100126:	eb 37                	jmp    8010015f <binit+0x6b>
    b->next = bcache.head.next;
80100128:	a1 70 0d 11 80       	mov    0x80110d70,%eax
8010012d:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
80100130:	c7 43 50 1c 0d 11 80 	movl   $0x80110d1c,0x50(%ebx)
    initsleeplock(&b->lock, "buffer");
80100137:	83 ec 08             	sub    $0x8,%esp
8010013a:	68 f8 64 10 80       	push   $0x801064f8
8010013f:	8d 43 0c             	lea    0xc(%ebx),%eax
80100142:	50                   	push   %eax
80100143:	e8 12 39 00 00       	call   80103a5a <initsleeplock>
    bcache.head.next->prev = b;
80100148:	a1 70 0d 11 80       	mov    0x80110d70,%eax
8010014d:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
80100150:	89 1d 70 0d 11 80    	mov    %ebx,0x80110d70
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100156:	81 c3 5c 02 00 00    	add    $0x25c,%ebx
8010015c:	83 c4 10             	add    $0x10,%esp
8010015f:	81 fb 1c 0d 11 80    	cmp    $0x80110d1c,%ebx
80100165:	72 c1                	jb     80100128 <binit+0x34>
}
80100167:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010016a:	c9                   	leave  
8010016b:	c3                   	ret    

8010016c <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
8010016c:	55                   	push   %ebp
8010016d:	89 e5                	mov    %esp,%ebp
8010016f:	53                   	push   %ebx
80100170:	83 ec 04             	sub    $0x4,%esp
  struct buf *b;

  b = bget(dev, blockno);
80100173:	8b 55 0c             	mov    0xc(%ebp),%edx
80100176:	8b 45 08             	mov    0x8(%ebp),%eax
80100179:	e8 b6 fe ff ff       	call   80100034 <bget>
8010017e:	89 c3                	mov    %eax,%ebx
  if((b->flags & B_VALID) == 0) {
80100180:	f6 00 02             	testb  $0x2,(%eax)
80100183:	74 07                	je     8010018c <bread+0x20>
    iderw(b);
  }
  return b;
}
80100185:	89 d8                	mov    %ebx,%eax
80100187:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010018a:	c9                   	leave  
8010018b:	c3                   	ret    
    iderw(b);
8010018c:	83 ec 0c             	sub    $0xc,%esp
8010018f:	50                   	push   %eax
80100190:	e8 ab 1c 00 00       	call   80101e40 <iderw>
80100195:	83 c4 10             	add    $0x10,%esp
  return b;
80100198:	eb eb                	jmp    80100185 <bread+0x19>

8010019a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
8010019a:	55                   	push   %ebp
8010019b:	89 e5                	mov    %esp,%ebp
8010019d:	53                   	push   %ebx
8010019e:	83 ec 10             	sub    $0x10,%esp
801001a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001a4:	8d 43 0c             	lea    0xc(%ebx),%eax
801001a7:	50                   	push   %eax
801001a8:	e8 6a 39 00 00       	call   80103b17 <holdingsleep>
801001ad:	83 c4 10             	add    $0x10,%esp
801001b0:	85 c0                	test   %eax,%eax
801001b2:	74 14                	je     801001c8 <bwrite+0x2e>
    panic("bwrite");
  b->flags |= B_DIRTY;
801001b4:	83 0b 04             	orl    $0x4,(%ebx)
  iderw(b);
801001b7:	83 ec 0c             	sub    $0xc,%esp
801001ba:	53                   	push   %ebx
801001bb:	e8 80 1c 00 00       	call   80101e40 <iderw>
}
801001c0:	83 c4 10             	add    $0x10,%esp
801001c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801001c6:	c9                   	leave  
801001c7:	c3                   	ret    
    panic("bwrite");
801001c8:	83 ec 0c             	sub    $0xc,%esp
801001cb:	68 ff 64 10 80       	push   $0x801064ff
801001d0:	e8 73 01 00 00       	call   80100348 <panic>

801001d5 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
801001d5:	55                   	push   %ebp
801001d6:	89 e5                	mov    %esp,%ebp
801001d8:	56                   	push   %esi
801001d9:	53                   	push   %ebx
801001da:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001dd:	8d 73 0c             	lea    0xc(%ebx),%esi
801001e0:	83 ec 0c             	sub    $0xc,%esp
801001e3:	56                   	push   %esi
801001e4:	e8 2e 39 00 00       	call   80103b17 <holdingsleep>
801001e9:	83 c4 10             	add    $0x10,%esp
801001ec:	85 c0                	test   %eax,%eax
801001ee:	74 6b                	je     8010025b <brelse+0x86>
    panic("brelse");

  releasesleep(&b->lock);
801001f0:	83 ec 0c             	sub    $0xc,%esp
801001f3:	56                   	push   %esi
801001f4:	e8 e3 38 00 00       	call   80103adc <releasesleep>

  acquire(&bcache.lock);
801001f9:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
80100200:	e8 75 3a 00 00       	call   80103c7a <acquire>
  b->refcnt--;
80100205:	8b 43 4c             	mov    0x4c(%ebx),%eax
80100208:	83 e8 01             	sub    $0x1,%eax
8010020b:	89 43 4c             	mov    %eax,0x4c(%ebx)
  if (b->refcnt == 0) {
8010020e:	83 c4 10             	add    $0x10,%esp
80100211:	85 c0                	test   %eax,%eax
80100213:	75 2f                	jne    80100244 <brelse+0x6f>
    // no one is waiting for it.
    b->next->prev = b->prev;
80100215:	8b 43 54             	mov    0x54(%ebx),%eax
80100218:	8b 53 50             	mov    0x50(%ebx),%edx
8010021b:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
8010021e:	8b 43 50             	mov    0x50(%ebx),%eax
80100221:	8b 53 54             	mov    0x54(%ebx),%edx
80100224:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
80100227:	a1 70 0d 11 80       	mov    0x80110d70,%eax
8010022c:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
8010022f:	c7 43 50 1c 0d 11 80 	movl   $0x80110d1c,0x50(%ebx)
    bcache.head.next->prev = b;
80100236:	a1 70 0d 11 80       	mov    0x80110d70,%eax
8010023b:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
8010023e:	89 1d 70 0d 11 80    	mov    %ebx,0x80110d70
  }
  
  release(&bcache.lock);
80100244:	83 ec 0c             	sub    $0xc,%esp
80100247:	68 20 c6 10 80       	push   $0x8010c620
8010024c:	e8 8e 3a 00 00       	call   80103cdf <release>
}
80100251:	83 c4 10             	add    $0x10,%esp
80100254:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100257:	5b                   	pop    %ebx
80100258:	5e                   	pop    %esi
80100259:	5d                   	pop    %ebp
8010025a:	c3                   	ret    
    panic("brelse");
8010025b:	83 ec 0c             	sub    $0xc,%esp
8010025e:	68 06 65 10 80       	push   $0x80106506
80100263:	e8 e0 00 00 00       	call   80100348 <panic>

80100268 <consoleread>:
#endif
}

int
consoleread(struct inode *ip, char *dst, int n)
{
80100268:	55                   	push   %ebp
80100269:	89 e5                	mov    %esp,%ebp
8010026b:	57                   	push   %edi
8010026c:	56                   	push   %esi
8010026d:	53                   	push   %ebx
8010026e:	83 ec 28             	sub    $0x28,%esp
80100271:	8b 7d 08             	mov    0x8(%ebp),%edi
80100274:	8b 75 0c             	mov    0xc(%ebp),%esi
80100277:	8b 5d 10             	mov    0x10(%ebp),%ebx
  uint target;
  int c;

  iunlock(ip);
8010027a:	57                   	push   %edi
8010027b:	e8 f7 13 00 00       	call   80101677 <iunlock>
  target = n;
80100280:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  acquire(&cons.lock);
80100283:	c7 04 24 20 95 10 80 	movl   $0x80109520,(%esp)
8010028a:	e8 eb 39 00 00       	call   80103c7a <acquire>
  while(n > 0){
8010028f:	83 c4 10             	add    $0x10,%esp
80100292:	85 db                	test   %ebx,%ebx
80100294:	0f 8e 8f 00 00 00    	jle    80100329 <consoleread+0xc1>
    while(input.r == input.w){
8010029a:	a1 00 10 11 80       	mov    0x80111000,%eax
8010029f:	3b 05 04 10 11 80    	cmp    0x80111004,%eax
801002a5:	75 47                	jne    801002ee <consoleread+0x86>
      if(myproc()->killed){
801002a7:	e8 95 2f 00 00       	call   80103241 <myproc>
801002ac:	83 78 28 00          	cmpl   $0x0,0x28(%eax)
801002b0:	75 17                	jne    801002c9 <consoleread+0x61>
        release(&cons.lock);
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
801002b2:	83 ec 08             	sub    $0x8,%esp
801002b5:	68 20 95 10 80       	push   $0x80109520
801002ba:	68 00 10 11 80       	push   $0x80111000
801002bf:	e8 4b 34 00 00       	call   8010370f <sleep>
801002c4:	83 c4 10             	add    $0x10,%esp
801002c7:	eb d1                	jmp    8010029a <consoleread+0x32>
        release(&cons.lock);
801002c9:	83 ec 0c             	sub    $0xc,%esp
801002cc:	68 20 95 10 80       	push   $0x80109520
801002d1:	e8 09 3a 00 00       	call   80103cdf <release>
        ilock(ip);
801002d6:	89 3c 24             	mov    %edi,(%esp)
801002d9:	e8 d7 12 00 00       	call   801015b5 <ilock>
        return -1;
801002de:	83 c4 10             	add    $0x10,%esp
801002e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  release(&cons.lock);
  ilock(ip);

  return target - n;
}
801002e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801002e9:	5b                   	pop    %ebx
801002ea:	5e                   	pop    %esi
801002eb:	5f                   	pop    %edi
801002ec:	5d                   	pop    %ebp
801002ed:	c3                   	ret    
    c = input.buf[input.r++ % INPUT_BUF];
801002ee:	8d 50 01             	lea    0x1(%eax),%edx
801002f1:	89 15 00 10 11 80    	mov    %edx,0x80111000
801002f7:	89 c2                	mov    %eax,%edx
801002f9:	83 e2 7f             	and    $0x7f,%edx
801002fc:	0f b6 8a 80 0f 11 80 	movzbl -0x7feef080(%edx),%ecx
80100303:	0f be d1             	movsbl %cl,%edx
    if(c == C('D')){  // EOF
80100306:	83 fa 04             	cmp    $0x4,%edx
80100309:	74 14                	je     8010031f <consoleread+0xb7>
    *dst++ = c;
8010030b:	8d 46 01             	lea    0x1(%esi),%eax
8010030e:	88 0e                	mov    %cl,(%esi)
    --n;
80100310:	83 eb 01             	sub    $0x1,%ebx
    if(c == '\n')
80100313:	83 fa 0a             	cmp    $0xa,%edx
80100316:	74 11                	je     80100329 <consoleread+0xc1>
    *dst++ = c;
80100318:	89 c6                	mov    %eax,%esi
8010031a:	e9 73 ff ff ff       	jmp    80100292 <consoleread+0x2a>
      if(n < target){
8010031f:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
80100322:	73 05                	jae    80100329 <consoleread+0xc1>
        input.r--;
80100324:	a3 00 10 11 80       	mov    %eax,0x80111000
  release(&cons.lock);
80100329:	83 ec 0c             	sub    $0xc,%esp
8010032c:	68 20 95 10 80       	push   $0x80109520
80100331:	e8 a9 39 00 00       	call   80103cdf <release>
  ilock(ip);
80100336:	89 3c 24             	mov    %edi,(%esp)
80100339:	e8 77 12 00 00       	call   801015b5 <ilock>
  return target - n;
8010033e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100341:	29 d8                	sub    %ebx,%eax
80100343:	83 c4 10             	add    $0x10,%esp
80100346:	eb 9e                	jmp    801002e6 <consoleread+0x7e>

80100348 <panic>:
{
80100348:	55                   	push   %ebp
80100349:	89 e5                	mov    %esp,%ebp
8010034b:	53                   	push   %ebx
8010034c:	83 ec 34             	sub    $0x34,%esp
}

static inline void
cli(void)
{
  asm volatile("cli");
8010034f:	fa                   	cli    
  cons.locking = 0;
80100350:	c7 05 54 95 10 80 00 	movl   $0x0,0x80109554
80100357:	00 00 00 
  cprintf("lapicid %d: panic: ", lapicid());
8010035a:	e8 53 20 00 00       	call   801023b2 <lapicid>
8010035f:	83 ec 08             	sub    $0x8,%esp
80100362:	50                   	push   %eax
80100363:	68 0d 65 10 80       	push   $0x8010650d
80100368:	e8 9e 02 00 00       	call   8010060b <cprintf>
  cprintf(s);
8010036d:	83 c4 04             	add    $0x4,%esp
80100370:	ff 75 08             	pushl  0x8(%ebp)
80100373:	e8 93 02 00 00       	call   8010060b <cprintf>
  cprintf("\n");
80100378:	c7 04 24 9b 6e 10 80 	movl   $0x80106e9b,(%esp)
8010037f:	e8 87 02 00 00       	call   8010060b <cprintf>
  getcallerpcs(&s, pcs);
80100384:	83 c4 08             	add    $0x8,%esp
80100387:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010038a:	50                   	push   %eax
8010038b:	8d 45 08             	lea    0x8(%ebp),%eax
8010038e:	50                   	push   %eax
8010038f:	e8 c5 37 00 00       	call   80103b59 <getcallerpcs>
  for(i=0; i<10; i++)
80100394:	83 c4 10             	add    $0x10,%esp
80100397:	bb 00 00 00 00       	mov    $0x0,%ebx
8010039c:	eb 17                	jmp    801003b5 <panic+0x6d>
    cprintf(" %p", pcs[i]);
8010039e:	83 ec 08             	sub    $0x8,%esp
801003a1:	ff 74 9d d0          	pushl  -0x30(%ebp,%ebx,4)
801003a5:	68 21 65 10 80       	push   $0x80106521
801003aa:	e8 5c 02 00 00       	call   8010060b <cprintf>
  for(i=0; i<10; i++)
801003af:	83 c3 01             	add    $0x1,%ebx
801003b2:	83 c4 10             	add    $0x10,%esp
801003b5:	83 fb 09             	cmp    $0x9,%ebx
801003b8:	7e e4                	jle    8010039e <panic+0x56>
  panicked = 1; // freeze other CPU
801003ba:	c7 05 58 95 10 80 01 	movl   $0x1,0x80109558
801003c1:	00 00 00 
801003c4:	eb fe                	jmp    801003c4 <panic+0x7c>

801003c6 <cgaputc>:
{
801003c6:	55                   	push   %ebp
801003c7:	89 e5                	mov    %esp,%ebp
801003c9:	57                   	push   %edi
801003ca:	56                   	push   %esi
801003cb:	53                   	push   %ebx
801003cc:	83 ec 0c             	sub    $0xc,%esp
801003cf:	89 c6                	mov    %eax,%esi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801003d1:	b9 d4 03 00 00       	mov    $0x3d4,%ecx
801003d6:	b8 0e 00 00 00       	mov    $0xe,%eax
801003db:	89 ca                	mov    %ecx,%edx
801003dd:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801003de:	bb d5 03 00 00       	mov    $0x3d5,%ebx
801003e3:	89 da                	mov    %ebx,%edx
801003e5:	ec                   	in     (%dx),%al
  pos = inb(CRTPORT+1) << 8;
801003e6:	0f b6 f8             	movzbl %al,%edi
801003e9:	c1 e7 08             	shl    $0x8,%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801003ec:	b8 0f 00 00 00       	mov    $0xf,%eax
801003f1:	89 ca                	mov    %ecx,%edx
801003f3:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801003f4:	89 da                	mov    %ebx,%edx
801003f6:	ec                   	in     (%dx),%al
  pos |= inb(CRTPORT+1);
801003f7:	0f b6 c8             	movzbl %al,%ecx
801003fa:	09 f9                	or     %edi,%ecx
  if(c == '\n')
801003fc:	83 fe 0a             	cmp    $0xa,%esi
801003ff:	74 6a                	je     8010046b <cgaputc+0xa5>
  else if(c == BACKSPACE){
80100401:	81 fe 00 01 00 00    	cmp    $0x100,%esi
80100407:	0f 84 81 00 00 00    	je     8010048e <cgaputc+0xc8>
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010040d:	89 f0                	mov    %esi,%eax
8010040f:	0f b6 f0             	movzbl %al,%esi
80100412:	8d 59 01             	lea    0x1(%ecx),%ebx
80100415:	66 81 ce 00 07       	or     $0x700,%si
8010041a:	66 89 b4 09 00 80 0b 	mov    %si,-0x7ff48000(%ecx,%ecx,1)
80100421:	80 
  if(pos < 0 || pos > 25*80)
80100422:	81 fb d0 07 00 00    	cmp    $0x7d0,%ebx
80100428:	77 71                	ja     8010049b <cgaputc+0xd5>
  if((pos/80) >= 24){  // Scroll up.
8010042a:	81 fb 7f 07 00 00    	cmp    $0x77f,%ebx
80100430:	7f 76                	jg     801004a8 <cgaputc+0xe2>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100432:	be d4 03 00 00       	mov    $0x3d4,%esi
80100437:	b8 0e 00 00 00       	mov    $0xe,%eax
8010043c:	89 f2                	mov    %esi,%edx
8010043e:	ee                   	out    %al,(%dx)
  outb(CRTPORT+1, pos>>8);
8010043f:	89 d8                	mov    %ebx,%eax
80100441:	c1 f8 08             	sar    $0x8,%eax
80100444:	b9 d5 03 00 00       	mov    $0x3d5,%ecx
80100449:	89 ca                	mov    %ecx,%edx
8010044b:	ee                   	out    %al,(%dx)
8010044c:	b8 0f 00 00 00       	mov    $0xf,%eax
80100451:	89 f2                	mov    %esi,%edx
80100453:	ee                   	out    %al,(%dx)
80100454:	89 d8                	mov    %ebx,%eax
80100456:	89 ca                	mov    %ecx,%edx
80100458:	ee                   	out    %al,(%dx)
  crt[pos] = ' ' | 0x0700;
80100459:	66 c7 84 1b 00 80 0b 	movw   $0x720,-0x7ff48000(%ebx,%ebx,1)
80100460:	80 20 07 
}
80100463:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100466:	5b                   	pop    %ebx
80100467:	5e                   	pop    %esi
80100468:	5f                   	pop    %edi
80100469:	5d                   	pop    %ebp
8010046a:	c3                   	ret    
    pos += 80 - pos%80;
8010046b:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100470:	89 c8                	mov    %ecx,%eax
80100472:	f7 ea                	imul   %edx
80100474:	c1 fa 05             	sar    $0x5,%edx
80100477:	8d 14 92             	lea    (%edx,%edx,4),%edx
8010047a:	89 d0                	mov    %edx,%eax
8010047c:	c1 e0 04             	shl    $0x4,%eax
8010047f:	89 ca                	mov    %ecx,%edx
80100481:	29 c2                	sub    %eax,%edx
80100483:	bb 50 00 00 00       	mov    $0x50,%ebx
80100488:	29 d3                	sub    %edx,%ebx
8010048a:	01 cb                	add    %ecx,%ebx
8010048c:	eb 94                	jmp    80100422 <cgaputc+0x5c>
    if(pos > 0) --pos;
8010048e:	85 c9                	test   %ecx,%ecx
80100490:	7e 05                	jle    80100497 <cgaputc+0xd1>
80100492:	8d 59 ff             	lea    -0x1(%ecx),%ebx
80100495:	eb 8b                	jmp    80100422 <cgaputc+0x5c>
  pos |= inb(CRTPORT+1);
80100497:	89 cb                	mov    %ecx,%ebx
80100499:	eb 87                	jmp    80100422 <cgaputc+0x5c>
    panic("pos under/overflow");
8010049b:	83 ec 0c             	sub    $0xc,%esp
8010049e:	68 25 65 10 80       	push   $0x80106525
801004a3:	e8 a0 fe ff ff       	call   80100348 <panic>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801004a8:	83 ec 04             	sub    $0x4,%esp
801004ab:	68 60 0e 00 00       	push   $0xe60
801004b0:	68 a0 80 0b 80       	push   $0x800b80a0
801004b5:	68 00 80 0b 80       	push   $0x800b8000
801004ba:	e8 e2 38 00 00       	call   80103da1 <memmove>
    pos -= 80;
801004bf:	83 eb 50             	sub    $0x50,%ebx
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801004c2:	b8 80 07 00 00       	mov    $0x780,%eax
801004c7:	29 d8                	sub    %ebx,%eax
801004c9:	8d 94 1b 00 80 0b 80 	lea    -0x7ff48000(%ebx,%ebx,1),%edx
801004d0:	83 c4 0c             	add    $0xc,%esp
801004d3:	01 c0                	add    %eax,%eax
801004d5:	50                   	push   %eax
801004d6:	6a 00                	push   $0x0
801004d8:	52                   	push   %edx
801004d9:	e8 48 38 00 00       	call   80103d26 <memset>
801004de:	83 c4 10             	add    $0x10,%esp
801004e1:	e9 4c ff ff ff       	jmp    80100432 <cgaputc+0x6c>

801004e6 <consputc>:
  if(panicked){
801004e6:	83 3d 58 95 10 80 00 	cmpl   $0x0,0x80109558
801004ed:	74 03                	je     801004f2 <consputc+0xc>
  asm volatile("cli");
801004ef:	fa                   	cli    
801004f0:	eb fe                	jmp    801004f0 <consputc+0xa>
{
801004f2:	55                   	push   %ebp
801004f3:	89 e5                	mov    %esp,%ebp
801004f5:	53                   	push   %ebx
801004f6:	83 ec 04             	sub    $0x4,%esp
801004f9:	89 c3                	mov    %eax,%ebx
  if(c == BACKSPACE){
801004fb:	3d 00 01 00 00       	cmp    $0x100,%eax
80100500:	74 18                	je     8010051a <consputc+0x34>
    uartputc(c);
80100502:	83 ec 0c             	sub    $0xc,%esp
80100505:	50                   	push   %eax
80100506:	e8 ce 4b 00 00       	call   801050d9 <uartputc>
8010050b:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
8010050e:	89 d8                	mov    %ebx,%eax
80100510:	e8 b1 fe ff ff       	call   801003c6 <cgaputc>
}
80100515:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100518:	c9                   	leave  
80100519:	c3                   	ret    
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010051a:	83 ec 0c             	sub    $0xc,%esp
8010051d:	6a 08                	push   $0x8
8010051f:	e8 b5 4b 00 00       	call   801050d9 <uartputc>
80100524:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010052b:	e8 a9 4b 00 00       	call   801050d9 <uartputc>
80100530:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100537:	e8 9d 4b 00 00       	call   801050d9 <uartputc>
8010053c:	83 c4 10             	add    $0x10,%esp
8010053f:	eb cd                	jmp    8010050e <consputc+0x28>

80100541 <printint>:
{
80100541:	55                   	push   %ebp
80100542:	89 e5                	mov    %esp,%ebp
80100544:	57                   	push   %edi
80100545:	56                   	push   %esi
80100546:	53                   	push   %ebx
80100547:	83 ec 1c             	sub    $0x1c,%esp
8010054a:	89 d7                	mov    %edx,%edi
  if(sign && (sign = xx < 0))
8010054c:	85 c9                	test   %ecx,%ecx
8010054e:	74 09                	je     80100559 <printint+0x18>
80100550:	89 c1                	mov    %eax,%ecx
80100552:	c1 e9 1f             	shr    $0x1f,%ecx
80100555:	85 c0                	test   %eax,%eax
80100557:	78 09                	js     80100562 <printint+0x21>
    x = xx;
80100559:	89 c2                	mov    %eax,%edx
  i = 0;
8010055b:	be 00 00 00 00       	mov    $0x0,%esi
80100560:	eb 08                	jmp    8010056a <printint+0x29>
    x = -xx;
80100562:	f7 d8                	neg    %eax
80100564:	89 c2                	mov    %eax,%edx
80100566:	eb f3                	jmp    8010055b <printint+0x1a>
    buf[i++] = digits[x % base];
80100568:	89 de                	mov    %ebx,%esi
8010056a:	89 d0                	mov    %edx,%eax
8010056c:	ba 00 00 00 00       	mov    $0x0,%edx
80100571:	f7 f7                	div    %edi
80100573:	8d 5e 01             	lea    0x1(%esi),%ebx
80100576:	0f b6 92 64 65 10 80 	movzbl -0x7fef9a9c(%edx),%edx
8010057d:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
80100581:	89 c2                	mov    %eax,%edx
80100583:	85 c0                	test   %eax,%eax
80100585:	75 e1                	jne    80100568 <printint+0x27>
  if(sign)
80100587:	85 c9                	test   %ecx,%ecx
80100589:	74 14                	je     8010059f <printint+0x5e>
    buf[i++] = '-';
8010058b:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
80100590:	8d 5e 02             	lea    0x2(%esi),%ebx
80100593:	eb 0a                	jmp    8010059f <printint+0x5e>
    consputc(buf[i]);
80100595:	0f be 44 1d d8       	movsbl -0x28(%ebp,%ebx,1),%eax
8010059a:	e8 47 ff ff ff       	call   801004e6 <consputc>
  while(--i >= 0)
8010059f:	83 eb 01             	sub    $0x1,%ebx
801005a2:	79 f1                	jns    80100595 <printint+0x54>
}
801005a4:	83 c4 1c             	add    $0x1c,%esp
801005a7:	5b                   	pop    %ebx
801005a8:	5e                   	pop    %esi
801005a9:	5f                   	pop    %edi
801005aa:	5d                   	pop    %ebp
801005ab:	c3                   	ret    

801005ac <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
801005ac:	55                   	push   %ebp
801005ad:	89 e5                	mov    %esp,%ebp
801005af:	57                   	push   %edi
801005b0:	56                   	push   %esi
801005b1:	53                   	push   %ebx
801005b2:	83 ec 18             	sub    $0x18,%esp
801005b5:	8b 7d 0c             	mov    0xc(%ebp),%edi
801005b8:	8b 75 10             	mov    0x10(%ebp),%esi
  int i;

  iunlock(ip);
801005bb:	ff 75 08             	pushl  0x8(%ebp)
801005be:	e8 b4 10 00 00       	call   80101677 <iunlock>
  acquire(&cons.lock);
801005c3:	c7 04 24 20 95 10 80 	movl   $0x80109520,(%esp)
801005ca:	e8 ab 36 00 00       	call   80103c7a <acquire>
  for(i = 0; i < n; i++)
801005cf:	83 c4 10             	add    $0x10,%esp
801005d2:	bb 00 00 00 00       	mov    $0x0,%ebx
801005d7:	eb 0c                	jmp    801005e5 <consolewrite+0x39>
    consputc(buf[i] & 0xff);
801005d9:	0f b6 04 1f          	movzbl (%edi,%ebx,1),%eax
801005dd:	e8 04 ff ff ff       	call   801004e6 <consputc>
  for(i = 0; i < n; i++)
801005e2:	83 c3 01             	add    $0x1,%ebx
801005e5:	39 f3                	cmp    %esi,%ebx
801005e7:	7c f0                	jl     801005d9 <consolewrite+0x2d>
  release(&cons.lock);
801005e9:	83 ec 0c             	sub    $0xc,%esp
801005ec:	68 20 95 10 80       	push   $0x80109520
801005f1:	e8 e9 36 00 00       	call   80103cdf <release>
  ilock(ip);
801005f6:	83 c4 04             	add    $0x4,%esp
801005f9:	ff 75 08             	pushl  0x8(%ebp)
801005fc:	e8 b4 0f 00 00       	call   801015b5 <ilock>

  return n;
}
80100601:	89 f0                	mov    %esi,%eax
80100603:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100606:	5b                   	pop    %ebx
80100607:	5e                   	pop    %esi
80100608:	5f                   	pop    %edi
80100609:	5d                   	pop    %ebp
8010060a:	c3                   	ret    

8010060b <cprintf>:
{
8010060b:	55                   	push   %ebp
8010060c:	89 e5                	mov    %esp,%ebp
8010060e:	57                   	push   %edi
8010060f:	56                   	push   %esi
80100610:	53                   	push   %ebx
80100611:	83 ec 1c             	sub    $0x1c,%esp
  locking = cons.locking;
80100614:	a1 54 95 10 80       	mov    0x80109554,%eax
80100619:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(locking)
8010061c:	85 c0                	test   %eax,%eax
8010061e:	75 10                	jne    80100630 <cprintf+0x25>
  if (fmt == 0)
80100620:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80100624:	74 1c                	je     80100642 <cprintf+0x37>
  argp = (uint*)(void*)(&fmt + 1);
80100626:	8d 7d 0c             	lea    0xc(%ebp),%edi
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100629:	bb 00 00 00 00       	mov    $0x0,%ebx
8010062e:	eb 27                	jmp    80100657 <cprintf+0x4c>
    acquire(&cons.lock);
80100630:	83 ec 0c             	sub    $0xc,%esp
80100633:	68 20 95 10 80       	push   $0x80109520
80100638:	e8 3d 36 00 00       	call   80103c7a <acquire>
8010063d:	83 c4 10             	add    $0x10,%esp
80100640:	eb de                	jmp    80100620 <cprintf+0x15>
    panic("null fmt");
80100642:	83 ec 0c             	sub    $0xc,%esp
80100645:	68 3f 65 10 80       	push   $0x8010653f
8010064a:	e8 f9 fc ff ff       	call   80100348 <panic>
      consputc(c);
8010064f:	e8 92 fe ff ff       	call   801004e6 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100654:	83 c3 01             	add    $0x1,%ebx
80100657:	8b 55 08             	mov    0x8(%ebp),%edx
8010065a:	0f b6 04 1a          	movzbl (%edx,%ebx,1),%eax
8010065e:	85 c0                	test   %eax,%eax
80100660:	0f 84 b8 00 00 00    	je     8010071e <cprintf+0x113>
    if(c != '%'){
80100666:	83 f8 25             	cmp    $0x25,%eax
80100669:	75 e4                	jne    8010064f <cprintf+0x44>
    c = fmt[++i] & 0xff;
8010066b:	83 c3 01             	add    $0x1,%ebx
8010066e:	0f b6 34 1a          	movzbl (%edx,%ebx,1),%esi
    if(c == 0)
80100672:	85 f6                	test   %esi,%esi
80100674:	0f 84 a4 00 00 00    	je     8010071e <cprintf+0x113>
    switch(c){
8010067a:	83 fe 70             	cmp    $0x70,%esi
8010067d:	74 48                	je     801006c7 <cprintf+0xbc>
8010067f:	83 fe 70             	cmp    $0x70,%esi
80100682:	7f 26                	jg     801006aa <cprintf+0x9f>
80100684:	83 fe 25             	cmp    $0x25,%esi
80100687:	0f 84 82 00 00 00    	je     8010070f <cprintf+0x104>
8010068d:	83 fe 64             	cmp    $0x64,%esi
80100690:	75 22                	jne    801006b4 <cprintf+0xa9>
      printint(*argp++, 10, 1);
80100692:	8d 77 04             	lea    0x4(%edi),%esi
80100695:	8b 07                	mov    (%edi),%eax
80100697:	b9 01 00 00 00       	mov    $0x1,%ecx
8010069c:	ba 0a 00 00 00       	mov    $0xa,%edx
801006a1:	e8 9b fe ff ff       	call   80100541 <printint>
801006a6:	89 f7                	mov    %esi,%edi
      break;
801006a8:	eb aa                	jmp    80100654 <cprintf+0x49>
    switch(c){
801006aa:	83 fe 73             	cmp    $0x73,%esi
801006ad:	74 33                	je     801006e2 <cprintf+0xd7>
801006af:	83 fe 78             	cmp    $0x78,%esi
801006b2:	74 13                	je     801006c7 <cprintf+0xbc>
      consputc('%');
801006b4:	b8 25 00 00 00       	mov    $0x25,%eax
801006b9:	e8 28 fe ff ff       	call   801004e6 <consputc>
      consputc(c);
801006be:	89 f0                	mov    %esi,%eax
801006c0:	e8 21 fe ff ff       	call   801004e6 <consputc>
      break;
801006c5:	eb 8d                	jmp    80100654 <cprintf+0x49>
      printint(*argp++, 16, 0);
801006c7:	8d 77 04             	lea    0x4(%edi),%esi
801006ca:	8b 07                	mov    (%edi),%eax
801006cc:	b9 00 00 00 00       	mov    $0x0,%ecx
801006d1:	ba 10 00 00 00       	mov    $0x10,%edx
801006d6:	e8 66 fe ff ff       	call   80100541 <printint>
801006db:	89 f7                	mov    %esi,%edi
      break;
801006dd:	e9 72 ff ff ff       	jmp    80100654 <cprintf+0x49>
      if((s = (char*)*argp++) == 0)
801006e2:	8d 47 04             	lea    0x4(%edi),%eax
801006e5:	89 45 e0             	mov    %eax,-0x20(%ebp)
801006e8:	8b 37                	mov    (%edi),%esi
801006ea:	85 f6                	test   %esi,%esi
801006ec:	75 12                	jne    80100700 <cprintf+0xf5>
        s = "(null)";
801006ee:	be 38 65 10 80       	mov    $0x80106538,%esi
801006f3:	eb 0b                	jmp    80100700 <cprintf+0xf5>
        consputc(*s);
801006f5:	0f be c0             	movsbl %al,%eax
801006f8:	e8 e9 fd ff ff       	call   801004e6 <consputc>
      for(; *s; s++)
801006fd:	83 c6 01             	add    $0x1,%esi
80100700:	0f b6 06             	movzbl (%esi),%eax
80100703:	84 c0                	test   %al,%al
80100705:	75 ee                	jne    801006f5 <cprintf+0xea>
      if((s = (char*)*argp++) == 0)
80100707:	8b 7d e0             	mov    -0x20(%ebp),%edi
8010070a:	e9 45 ff ff ff       	jmp    80100654 <cprintf+0x49>
      consputc('%');
8010070f:	b8 25 00 00 00       	mov    $0x25,%eax
80100714:	e8 cd fd ff ff       	call   801004e6 <consputc>
      break;
80100719:	e9 36 ff ff ff       	jmp    80100654 <cprintf+0x49>
  if(locking)
8010071e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100722:	75 08                	jne    8010072c <cprintf+0x121>
}
80100724:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100727:	5b                   	pop    %ebx
80100728:	5e                   	pop    %esi
80100729:	5f                   	pop    %edi
8010072a:	5d                   	pop    %ebp
8010072b:	c3                   	ret    
    release(&cons.lock);
8010072c:	83 ec 0c             	sub    $0xc,%esp
8010072f:	68 20 95 10 80       	push   $0x80109520
80100734:	e8 a6 35 00 00       	call   80103cdf <release>
80100739:	83 c4 10             	add    $0x10,%esp
}
8010073c:	eb e6                	jmp    80100724 <cprintf+0x119>

8010073e <do_shutdown>:
{
8010073e:	55                   	push   %ebp
8010073f:	89 e5                	mov    %esp,%ebp
80100741:	83 ec 14             	sub    $0x14,%esp
  cprintf("\nShutting down ...\n");
80100744:	68 48 65 10 80       	push   $0x80106548
80100749:	e8 bd fe ff ff       	call   8010060b <cprintf>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010074e:	b8 00 20 00 00       	mov    $0x2000,%eax
80100753:	ba 04 06 00 00       	mov    $0x604,%edx
80100758:	66 ef                	out    %ax,(%dx)
  return;  // not reached
8010075a:	83 c4 10             	add    $0x10,%esp
}
8010075d:	c9                   	leave  
8010075e:	c3                   	ret    

8010075f <consoleintr>:
{
8010075f:	55                   	push   %ebp
80100760:	89 e5                	mov    %esp,%ebp
80100762:	57                   	push   %edi
80100763:	56                   	push   %esi
80100764:	53                   	push   %ebx
80100765:	83 ec 28             	sub    $0x28,%esp
80100768:	8b 75 08             	mov    0x8(%ebp),%esi
  acquire(&cons.lock);
8010076b:	68 20 95 10 80       	push   $0x80109520
80100770:	e8 05 35 00 00       	call   80103c7a <acquire>
  while((c = getc()) >= 0){
80100775:	83 c4 10             	add    $0x10,%esp
  int shutdown = FALSE;
80100778:	bf 00 00 00 00       	mov    $0x0,%edi
  int c, doprocdump = 0;
8010077d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  while((c = getc()) >= 0){
80100784:	eb 36                	jmp    801007bc <consoleintr+0x5d>
    switch(c){
80100786:	83 fb 15             	cmp    $0x15,%ebx
80100789:	0f 84 d7 00 00 00    	je     80100866 <consoleintr+0x107>
8010078f:	83 fb 7f             	cmp    $0x7f,%ebx
80100792:	75 4c                	jne    801007e0 <consoleintr+0x81>
      if(input.e != input.w){
80100794:	a1 08 10 11 80       	mov    0x80111008,%eax
80100799:	3b 05 04 10 11 80    	cmp    0x80111004,%eax
8010079f:	74 1b                	je     801007bc <consoleintr+0x5d>
        input.e--;
801007a1:	83 e8 01             	sub    $0x1,%eax
801007a4:	a3 08 10 11 80       	mov    %eax,0x80111008
        consputc(BACKSPACE);
801007a9:	b8 00 01 00 00       	mov    $0x100,%eax
801007ae:	e8 33 fd ff ff       	call   801004e6 <consputc>
801007b3:	eb 07                	jmp    801007bc <consoleintr+0x5d>
      doprocdump = 1;
801007b5:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  while((c = getc()) >= 0){
801007bc:	ff d6                	call   *%esi
801007be:	89 c3                	mov    %eax,%ebx
801007c0:	85 c0                	test   %eax,%eax
801007c2:	0f 88 d9 00 00 00    	js     801008a1 <consoleintr+0x142>
    switch(c){
801007c8:	83 fb 10             	cmp    $0x10,%ebx
801007cb:	74 e8                	je     801007b5 <consoleintr+0x56>
801007cd:	83 fb 10             	cmp    $0x10,%ebx
801007d0:	7f b4                	jg     80100786 <consoleintr+0x27>
801007d2:	83 fb 04             	cmp    $0x4,%ebx
801007d5:	0f 84 bc 00 00 00    	je     80100897 <consoleintr+0x138>
801007db:	83 fb 08             	cmp    $0x8,%ebx
801007de:	74 b4                	je     80100794 <consoleintr+0x35>
      if(c != 0 && input.e-input.r < INPUT_BUF){
801007e0:	85 db                	test   %ebx,%ebx
801007e2:	74 d8                	je     801007bc <consoleintr+0x5d>
801007e4:	a1 08 10 11 80       	mov    0x80111008,%eax
801007e9:	89 c2                	mov    %eax,%edx
801007eb:	2b 15 00 10 11 80    	sub    0x80111000,%edx
801007f1:	83 fa 7f             	cmp    $0x7f,%edx
801007f4:	77 c6                	ja     801007bc <consoleintr+0x5d>
        c = (c == '\r') ? '\n' : c;
801007f6:	83 fb 0d             	cmp    $0xd,%ebx
801007f9:	0f 84 8e 00 00 00    	je     8010088d <consoleintr+0x12e>
        input.buf[input.e++ % INPUT_BUF] = c;
801007ff:	8d 50 01             	lea    0x1(%eax),%edx
80100802:	89 15 08 10 11 80    	mov    %edx,0x80111008
80100808:	83 e0 7f             	and    $0x7f,%eax
8010080b:	88 98 80 0f 11 80    	mov    %bl,-0x7feef080(%eax)
        consputc(c);
80100811:	89 d8                	mov    %ebx,%eax
80100813:	e8 ce fc ff ff       	call   801004e6 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100818:	83 fb 0a             	cmp    $0xa,%ebx
8010081b:	0f 94 c2             	sete   %dl
8010081e:	83 fb 04             	cmp    $0x4,%ebx
80100821:	0f 94 c0             	sete   %al
80100824:	08 c2                	or     %al,%dl
80100826:	75 10                	jne    80100838 <consoleintr+0xd9>
80100828:	a1 00 10 11 80       	mov    0x80111000,%eax
8010082d:	83 e8 80             	sub    $0xffffff80,%eax
80100830:	39 05 08 10 11 80    	cmp    %eax,0x80111008
80100836:	75 84                	jne    801007bc <consoleintr+0x5d>
          input.w = input.e;
80100838:	a1 08 10 11 80       	mov    0x80111008,%eax
8010083d:	a3 04 10 11 80       	mov    %eax,0x80111004
          wakeup(&input.r);
80100842:	83 ec 0c             	sub    $0xc,%esp
80100845:	68 00 10 11 80       	push   $0x80111000
8010084a:	e8 24 30 00 00       	call   80103873 <wakeup>
8010084f:	83 c4 10             	add    $0x10,%esp
80100852:	e9 65 ff ff ff       	jmp    801007bc <consoleintr+0x5d>
        input.e--;
80100857:	a3 08 10 11 80       	mov    %eax,0x80111008
        consputc(BACKSPACE);
8010085c:	b8 00 01 00 00       	mov    $0x100,%eax
80100861:	e8 80 fc ff ff       	call   801004e6 <consputc>
      while(input.e != input.w &&
80100866:	a1 08 10 11 80       	mov    0x80111008,%eax
8010086b:	3b 05 04 10 11 80    	cmp    0x80111004,%eax
80100871:	0f 84 45 ff ff ff    	je     801007bc <consoleintr+0x5d>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100877:	83 e8 01             	sub    $0x1,%eax
8010087a:	89 c2                	mov    %eax,%edx
8010087c:	83 e2 7f             	and    $0x7f,%edx
      while(input.e != input.w &&
8010087f:	80 ba 80 0f 11 80 0a 	cmpb   $0xa,-0x7feef080(%edx)
80100886:	75 cf                	jne    80100857 <consoleintr+0xf8>
80100888:	e9 2f ff ff ff       	jmp    801007bc <consoleintr+0x5d>
        c = (c == '\r') ? '\n' : c;
8010088d:	bb 0a 00 00 00       	mov    $0xa,%ebx
80100892:	e9 68 ff ff ff       	jmp    801007ff <consoleintr+0xa0>
      shutdown = TRUE;
80100897:	bf 01 00 00 00       	mov    $0x1,%edi
8010089c:	e9 1b ff ff ff       	jmp    801007bc <consoleintr+0x5d>
  release(&cons.lock);
801008a1:	83 ec 0c             	sub    $0xc,%esp
801008a4:	68 20 95 10 80       	push   $0x80109520
801008a9:	e8 31 34 00 00       	call   80103cdf <release>
  if (shutdown)
801008ae:	83 c4 10             	add    $0x10,%esp
801008b1:	85 ff                	test   %edi,%edi
801008b3:	75 0e                	jne    801008c3 <consoleintr+0x164>
  if(doprocdump) {
801008b5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801008b9:	75 0f                	jne    801008ca <consoleintr+0x16b>
}
801008bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
801008be:	5b                   	pop    %ebx
801008bf:	5e                   	pop    %esi
801008c0:	5f                   	pop    %edi
801008c1:	5d                   	pop    %ebp
801008c2:	c3                   	ret    
    do_shutdown();
801008c3:	e8 76 fe ff ff       	call   8010073e <do_shutdown>
801008c8:	eb eb                	jmp    801008b5 <consoleintr+0x156>
    procdump();  // now call procdump() wo. cons.lock held
801008ca:	e8 c4 30 00 00       	call   80103993 <procdump>
}
801008cf:	eb ea                	jmp    801008bb <consoleintr+0x15c>

801008d1 <consoleinit>:

void
consoleinit(void)
{
801008d1:	55                   	push   %ebp
801008d2:	89 e5                	mov    %esp,%ebp
801008d4:	83 ec 10             	sub    $0x10,%esp
  initlock(&cons.lock, "console");
801008d7:	68 5c 65 10 80       	push   $0x8010655c
801008dc:	68 20 95 10 80       	push   $0x80109520
801008e1:	e8 58 32 00 00       	call   80103b3e <initlock>

  devsw[CONSOLE].write = consolewrite;
801008e6:	c7 05 cc 19 11 80 ac 	movl   $0x801005ac,0x801119cc
801008ed:	05 10 80 
  devsw[CONSOLE].read = consoleread;
801008f0:	c7 05 c8 19 11 80 68 	movl   $0x80100268,0x801119c8
801008f7:	02 10 80 
  cons.locking = 1;
801008fa:	c7 05 54 95 10 80 01 	movl   $0x1,0x80109554
80100901:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100904:	83 c4 08             	add    $0x8,%esp
80100907:	6a 00                	push   $0x0
80100909:	6a 01                	push   $0x1
8010090b:	e8 a2 16 00 00       	call   80101fb2 <ioapicenable>
}
80100910:	83 c4 10             	add    $0x10,%esp
80100913:	c9                   	leave  
80100914:	c3                   	ret    

80100915 <exec>:
#include "elf.h"


int
exec(char *path, char **argv)
{
80100915:	55                   	push   %ebp
80100916:	89 e5                	mov    %esp,%ebp
80100918:	57                   	push   %edi
80100919:	56                   	push   %esi
8010091a:	53                   	push   %ebx
8010091b:	81 ec 0c 01 00 00    	sub    $0x10c,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100921:	e8 1b 29 00 00       	call   80103241 <myproc>
80100926:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)

  begin_op();
8010092c:	e8 b1 1e 00 00       	call   801027e2 <begin_op>

  if((ip = namei(path)) == 0){
80100931:	83 ec 0c             	sub    $0xc,%esp
80100934:	ff 75 08             	pushl  0x8(%ebp)
80100937:	e8 d9 12 00 00       	call   80101c15 <namei>
8010093c:	83 c4 10             	add    $0x10,%esp
8010093f:	85 c0                	test   %eax,%eax
80100941:	74 4a                	je     8010098d <exec+0x78>
80100943:	89 c3                	mov    %eax,%ebx
#ifndef PDX_XV6
    cprintf("exec: fail\n");
#endif
    return -1;
  }
  ilock(ip);
80100945:	83 ec 0c             	sub    $0xc,%esp
80100948:	50                   	push   %eax
80100949:	e8 67 0c 00 00       	call   801015b5 <ilock>
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
8010094e:	6a 34                	push   $0x34
80100950:	6a 00                	push   $0x0
80100952:	8d 85 24 ff ff ff    	lea    -0xdc(%ebp),%eax
80100958:	50                   	push   %eax
80100959:	53                   	push   %ebx
8010095a:	e8 48 0e 00 00       	call   801017a7 <readi>
8010095f:	83 c4 20             	add    $0x20,%esp
80100962:	83 f8 34             	cmp    $0x34,%eax
80100965:	74 32                	je     80100999 <exec+0x84>
  return 0;

bad:
  if(pgdir)
    freevm(pgdir);
  if(ip){
80100967:	85 db                	test   %ebx,%ebx
80100969:	0f 84 ce 02 00 00    	je     80100c3d <exec+0x328>
    iunlockput(ip);
8010096f:	83 ec 0c             	sub    $0xc,%esp
80100972:	53                   	push   %ebx
80100973:	e8 e4 0d 00 00       	call   8010175c <iunlockput>
    end_op();
80100978:	e8 df 1e 00 00       	call   8010285c <end_op>
8010097d:	83 c4 10             	add    $0x10,%esp
  }
  return -1;
80100980:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100985:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100988:	5b                   	pop    %ebx
80100989:	5e                   	pop    %esi
8010098a:	5f                   	pop    %edi
8010098b:	5d                   	pop    %ebp
8010098c:	c3                   	ret    
    end_op();
8010098d:	e8 ca 1e 00 00       	call   8010285c <end_op>
    return -1;
80100992:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100997:	eb ec                	jmp    80100985 <exec+0x70>
  if(elf.magic != ELF_MAGIC)
80100999:	81 bd 24 ff ff ff 7f 	cmpl   $0x464c457f,-0xdc(%ebp)
801009a0:	45 4c 46 
801009a3:	75 c2                	jne    80100967 <exec+0x52>
  if((pgdir = setupkvm()) == 0)
801009a5:	e8 ef 58 00 00       	call   80106299 <setupkvm>
801009aa:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)
801009b0:	85 c0                	test   %eax,%eax
801009b2:	0f 84 06 01 00 00    	je     80100abe <exec+0x1a9>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
801009b8:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  sz = 0;
801009be:	bf 00 00 00 00       	mov    $0x0,%edi
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
801009c3:	be 00 00 00 00       	mov    $0x0,%esi
801009c8:	eb 0c                	jmp    801009d6 <exec+0xc1>
801009ca:	83 c6 01             	add    $0x1,%esi
801009cd:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
801009d3:	83 c0 20             	add    $0x20,%eax
801009d6:	0f b7 95 50 ff ff ff 	movzwl -0xb0(%ebp),%edx
801009dd:	39 f2                	cmp    %esi,%edx
801009df:	0f 8e 98 00 00 00    	jle    80100a7d <exec+0x168>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
801009e5:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
801009eb:	6a 20                	push   $0x20
801009ed:	50                   	push   %eax
801009ee:	8d 85 04 ff ff ff    	lea    -0xfc(%ebp),%eax
801009f4:	50                   	push   %eax
801009f5:	53                   	push   %ebx
801009f6:	e8 ac 0d 00 00       	call   801017a7 <readi>
801009fb:	83 c4 10             	add    $0x10,%esp
801009fe:	83 f8 20             	cmp    $0x20,%eax
80100a01:	0f 85 b7 00 00 00    	jne    80100abe <exec+0x1a9>
    if(ph.type != ELF_PROG_LOAD)
80100a07:	83 bd 04 ff ff ff 01 	cmpl   $0x1,-0xfc(%ebp)
80100a0e:	75 ba                	jne    801009ca <exec+0xb5>
    if(ph.memsz < ph.filesz)
80100a10:	8b 85 18 ff ff ff    	mov    -0xe8(%ebp),%eax
80100a16:	3b 85 14 ff ff ff    	cmp    -0xec(%ebp),%eax
80100a1c:	0f 82 9c 00 00 00    	jb     80100abe <exec+0x1a9>
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100a22:	03 85 0c ff ff ff    	add    -0xf4(%ebp),%eax
80100a28:	0f 82 90 00 00 00    	jb     80100abe <exec+0x1a9>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100a2e:	83 ec 04             	sub    $0x4,%esp
80100a31:	50                   	push   %eax
80100a32:	57                   	push   %edi
80100a33:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100a39:	e8 01 57 00 00       	call   8010613f <allocuvm>
80100a3e:	89 c7                	mov    %eax,%edi
80100a40:	83 c4 10             	add    $0x10,%esp
80100a43:	85 c0                	test   %eax,%eax
80100a45:	74 77                	je     80100abe <exec+0x1a9>
    if(ph.vaddr % PGSIZE != 0)
80100a47:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100a4d:	a9 ff 0f 00 00       	test   $0xfff,%eax
80100a52:	75 6a                	jne    80100abe <exec+0x1a9>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100a54:	83 ec 0c             	sub    $0xc,%esp
80100a57:	ff b5 14 ff ff ff    	pushl  -0xec(%ebp)
80100a5d:	ff b5 08 ff ff ff    	pushl  -0xf8(%ebp)
80100a63:	53                   	push   %ebx
80100a64:	50                   	push   %eax
80100a65:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100a6b:	e8 9d 55 00 00       	call   8010600d <loaduvm>
80100a70:	83 c4 20             	add    $0x20,%esp
80100a73:	85 c0                	test   %eax,%eax
80100a75:	0f 89 4f ff ff ff    	jns    801009ca <exec+0xb5>
bad:
80100a7b:	eb 41                	jmp    80100abe <exec+0x1a9>
  iunlockput(ip);
80100a7d:	83 ec 0c             	sub    $0xc,%esp
80100a80:	53                   	push   %ebx
80100a81:	e8 d6 0c 00 00       	call   8010175c <iunlockput>
  end_op();
80100a86:	e8 d1 1d 00 00       	call   8010285c <end_op>
  sz = PGROUNDUP(sz);
80100a8b:	8d 87 ff 0f 00 00    	lea    0xfff(%edi),%eax
80100a91:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100a96:	83 c4 0c             	add    $0xc,%esp
80100a99:	8d 90 00 20 00 00    	lea    0x2000(%eax),%edx
80100a9f:	52                   	push   %edx
80100aa0:	50                   	push   %eax
80100aa1:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100aa7:	e8 93 56 00 00       	call   8010613f <allocuvm>
80100aac:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
80100ab2:	83 c4 10             	add    $0x10,%esp
80100ab5:	85 c0                	test   %eax,%eax
80100ab7:	75 24                	jne    80100add <exec+0x1c8>
  ip = 0;
80100ab9:	bb 00 00 00 00       	mov    $0x0,%ebx
  if(pgdir)
80100abe:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100ac4:	85 c0                	test   %eax,%eax
80100ac6:	0f 84 9b fe ff ff    	je     80100967 <exec+0x52>
    freevm(pgdir);
80100acc:	83 ec 0c             	sub    $0xc,%esp
80100acf:	50                   	push   %eax
80100ad0:	e8 54 57 00 00       	call   80106229 <freevm>
80100ad5:	83 c4 10             	add    $0x10,%esp
80100ad8:	e9 8a fe ff ff       	jmp    80100967 <exec+0x52>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100add:	89 c7                	mov    %eax,%edi
80100adf:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
80100ae5:	83 ec 08             	sub    $0x8,%esp
80100ae8:	50                   	push   %eax
80100ae9:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100aef:	e8 2a 58 00 00       	call   8010631e <clearpteu>
  for(argc = 0; argv[argc]; argc++) {
80100af4:	83 c4 10             	add    $0x10,%esp
80100af7:	bb 00 00 00 00       	mov    $0x0,%ebx
80100afc:	8b 45 0c             	mov    0xc(%ebp),%eax
80100aff:	8d 34 98             	lea    (%eax,%ebx,4),%esi
80100b02:	8b 06                	mov    (%esi),%eax
80100b04:	85 c0                	test   %eax,%eax
80100b06:	74 4d                	je     80100b55 <exec+0x240>
    if(argc >= MAXARG)
80100b08:	83 fb 1f             	cmp    $0x1f,%ebx
80100b0b:	0f 87 0e 01 00 00    	ja     80100c1f <exec+0x30a>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100b11:	83 ec 0c             	sub    $0xc,%esp
80100b14:	50                   	push   %eax
80100b15:	e8 ae 33 00 00       	call   80103ec8 <strlen>
80100b1a:	29 c7                	sub    %eax,%edi
80100b1c:	83 ef 01             	sub    $0x1,%edi
80100b1f:	83 e7 fc             	and    $0xfffffffc,%edi
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100b22:	83 c4 04             	add    $0x4,%esp
80100b25:	ff 36                	pushl  (%esi)
80100b27:	e8 9c 33 00 00       	call   80103ec8 <strlen>
80100b2c:	83 c0 01             	add    $0x1,%eax
80100b2f:	50                   	push   %eax
80100b30:	ff 36                	pushl  (%esi)
80100b32:	57                   	push   %edi
80100b33:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100b39:	e8 22 59 00 00       	call   80106460 <copyout>
80100b3e:	83 c4 20             	add    $0x20,%esp
80100b41:	85 c0                	test   %eax,%eax
80100b43:	0f 88 e0 00 00 00    	js     80100c29 <exec+0x314>
    ustack[3+argc] = sp;
80100b49:	89 bc 9d 64 ff ff ff 	mov    %edi,-0x9c(%ebp,%ebx,4)
  for(argc = 0; argv[argc]; argc++) {
80100b50:	83 c3 01             	add    $0x1,%ebx
80100b53:	eb a7                	jmp    80100afc <exec+0x1e7>
  ustack[3+argc] = 0;
80100b55:	c7 84 9d 64 ff ff ff 	movl   $0x0,-0x9c(%ebp,%ebx,4)
80100b5c:	00 00 00 00 
  ustack[0] = 0xffffffff;  // fake return PC
80100b60:	c7 85 58 ff ff ff ff 	movl   $0xffffffff,-0xa8(%ebp)
80100b67:	ff ff ff 
  ustack[1] = argc;
80100b6a:	89 9d 5c ff ff ff    	mov    %ebx,-0xa4(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100b70:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
80100b77:	89 f9                	mov    %edi,%ecx
80100b79:	29 c1                	sub    %eax,%ecx
80100b7b:	89 8d 60 ff ff ff    	mov    %ecx,-0xa0(%ebp)
  sp -= (3+argc+1) * 4;
80100b81:	8d 04 9d 10 00 00 00 	lea    0x10(,%ebx,4),%eax
80100b88:	29 c7                	sub    %eax,%edi
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100b8a:	50                   	push   %eax
80100b8b:	8d 85 58 ff ff ff    	lea    -0xa8(%ebp),%eax
80100b91:	50                   	push   %eax
80100b92:	57                   	push   %edi
80100b93:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100b99:	e8 c2 58 00 00       	call   80106460 <copyout>
80100b9e:	83 c4 10             	add    $0x10,%esp
80100ba1:	85 c0                	test   %eax,%eax
80100ba3:	0f 88 8a 00 00 00    	js     80100c33 <exec+0x31e>
  for(last=s=path; *s; s++)
80100ba9:	8b 55 08             	mov    0x8(%ebp),%edx
80100bac:	89 d0                	mov    %edx,%eax
80100bae:	eb 03                	jmp    80100bb3 <exec+0x29e>
80100bb0:	83 c0 01             	add    $0x1,%eax
80100bb3:	0f b6 08             	movzbl (%eax),%ecx
80100bb6:	84 c9                	test   %cl,%cl
80100bb8:	74 0a                	je     80100bc4 <exec+0x2af>
    if(*s == '/')
80100bba:	80 f9 2f             	cmp    $0x2f,%cl
80100bbd:	75 f1                	jne    80100bb0 <exec+0x29b>
      last = s+1;
80100bbf:	8d 50 01             	lea    0x1(%eax),%edx
80100bc2:	eb ec                	jmp    80100bb0 <exec+0x29b>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100bc4:	8b b5 f4 fe ff ff    	mov    -0x10c(%ebp),%esi
80100bca:	89 f0                	mov    %esi,%eax
80100bcc:	83 c0 70             	add    $0x70,%eax
80100bcf:	83 ec 04             	sub    $0x4,%esp
80100bd2:	6a 10                	push   $0x10
80100bd4:	52                   	push   %edx
80100bd5:	50                   	push   %eax
80100bd6:	e8 b2 32 00 00       	call   80103e8d <safestrcpy>
  oldpgdir = curproc->pgdir;
80100bdb:	8b 5e 08             	mov    0x8(%esi),%ebx
  curproc->pgdir = pgdir;
80100bde:	8b 8d ec fe ff ff    	mov    -0x114(%ebp),%ecx
80100be4:	89 4e 08             	mov    %ecx,0x8(%esi)
  curproc->sz = sz;
80100be7:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100bed:	89 4e 04             	mov    %ecx,0x4(%esi)
  curproc->tf->eip = elf.entry;  // main
80100bf0:	8b 46 1c             	mov    0x1c(%esi),%eax
80100bf3:	8b 95 3c ff ff ff    	mov    -0xc4(%ebp),%edx
80100bf9:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100bfc:	8b 46 1c             	mov    0x1c(%esi),%eax
80100bff:	89 78 44             	mov    %edi,0x44(%eax)
  switchuvm(curproc);
80100c02:	89 34 24             	mov    %esi,(%esp)
80100c05:	e8 82 52 00 00       	call   80105e8c <switchuvm>
  freevm(oldpgdir);
80100c0a:	89 1c 24             	mov    %ebx,(%esp)
80100c0d:	e8 17 56 00 00       	call   80106229 <freevm>
  return 0;
80100c12:	83 c4 10             	add    $0x10,%esp
80100c15:	b8 00 00 00 00       	mov    $0x0,%eax
80100c1a:	e9 66 fd ff ff       	jmp    80100985 <exec+0x70>
  ip = 0;
80100c1f:	bb 00 00 00 00       	mov    $0x0,%ebx
80100c24:	e9 95 fe ff ff       	jmp    80100abe <exec+0x1a9>
80100c29:	bb 00 00 00 00       	mov    $0x0,%ebx
80100c2e:	e9 8b fe ff ff       	jmp    80100abe <exec+0x1a9>
80100c33:	bb 00 00 00 00       	mov    $0x0,%ebx
80100c38:	e9 81 fe ff ff       	jmp    80100abe <exec+0x1a9>
  return -1;
80100c3d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c42:	e9 3e fd ff ff       	jmp    80100985 <exec+0x70>

80100c47 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100c47:	55                   	push   %ebp
80100c48:	89 e5                	mov    %esp,%ebp
80100c4a:	83 ec 10             	sub    $0x10,%esp
  initlock(&ftable.lock, "ftable");
80100c4d:	68 75 65 10 80       	push   $0x80106575
80100c52:	68 20 10 11 80       	push   $0x80111020
80100c57:	e8 e2 2e 00 00       	call   80103b3e <initlock>
}
80100c5c:	83 c4 10             	add    $0x10,%esp
80100c5f:	c9                   	leave  
80100c60:	c3                   	ret    

80100c61 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100c61:	55                   	push   %ebp
80100c62:	89 e5                	mov    %esp,%ebp
80100c64:	53                   	push   %ebx
80100c65:	83 ec 10             	sub    $0x10,%esp
  struct file *f;

  acquire(&ftable.lock);
80100c68:	68 20 10 11 80       	push   $0x80111020
80100c6d:	e8 08 30 00 00       	call   80103c7a <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100c72:	83 c4 10             	add    $0x10,%esp
80100c75:	bb 54 10 11 80       	mov    $0x80111054,%ebx
80100c7a:	81 fb b4 19 11 80    	cmp    $0x801119b4,%ebx
80100c80:	73 29                	jae    80100cab <filealloc+0x4a>
    if(f->ref == 0){
80100c82:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
80100c86:	74 05                	je     80100c8d <filealloc+0x2c>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100c88:	83 c3 18             	add    $0x18,%ebx
80100c8b:	eb ed                	jmp    80100c7a <filealloc+0x19>
      f->ref = 1;
80100c8d:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%ebx)
      release(&ftable.lock);
80100c94:	83 ec 0c             	sub    $0xc,%esp
80100c97:	68 20 10 11 80       	push   $0x80111020
80100c9c:	e8 3e 30 00 00       	call   80103cdf <release>
      return f;
80100ca1:	83 c4 10             	add    $0x10,%esp
    }
  }
  release(&ftable.lock);
  return 0;
}
80100ca4:	89 d8                	mov    %ebx,%eax
80100ca6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100ca9:	c9                   	leave  
80100caa:	c3                   	ret    
  release(&ftable.lock);
80100cab:	83 ec 0c             	sub    $0xc,%esp
80100cae:	68 20 10 11 80       	push   $0x80111020
80100cb3:	e8 27 30 00 00       	call   80103cdf <release>
  return 0;
80100cb8:	83 c4 10             	add    $0x10,%esp
80100cbb:	bb 00 00 00 00       	mov    $0x0,%ebx
80100cc0:	eb e2                	jmp    80100ca4 <filealloc+0x43>

80100cc2 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100cc2:	55                   	push   %ebp
80100cc3:	89 e5                	mov    %esp,%ebp
80100cc5:	53                   	push   %ebx
80100cc6:	83 ec 10             	sub    $0x10,%esp
80100cc9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ftable.lock);
80100ccc:	68 20 10 11 80       	push   $0x80111020
80100cd1:	e8 a4 2f 00 00       	call   80103c7a <acquire>
  if(f->ref < 1)
80100cd6:	8b 43 04             	mov    0x4(%ebx),%eax
80100cd9:	83 c4 10             	add    $0x10,%esp
80100cdc:	85 c0                	test   %eax,%eax
80100cde:	7e 1a                	jle    80100cfa <filedup+0x38>
    panic("filedup");
  f->ref++;
80100ce0:	83 c0 01             	add    $0x1,%eax
80100ce3:	89 43 04             	mov    %eax,0x4(%ebx)
  release(&ftable.lock);
80100ce6:	83 ec 0c             	sub    $0xc,%esp
80100ce9:	68 20 10 11 80       	push   $0x80111020
80100cee:	e8 ec 2f 00 00       	call   80103cdf <release>
  return f;
}
80100cf3:	89 d8                	mov    %ebx,%eax
80100cf5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100cf8:	c9                   	leave  
80100cf9:	c3                   	ret    
    panic("filedup");
80100cfa:	83 ec 0c             	sub    $0xc,%esp
80100cfd:	68 7c 65 10 80       	push   $0x8010657c
80100d02:	e8 41 f6 ff ff       	call   80100348 <panic>

80100d07 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100d07:	55                   	push   %ebp
80100d08:	89 e5                	mov    %esp,%ebp
80100d0a:	53                   	push   %ebx
80100d0b:	83 ec 30             	sub    $0x30,%esp
80100d0e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct file ff;

  acquire(&ftable.lock);
80100d11:	68 20 10 11 80       	push   $0x80111020
80100d16:	e8 5f 2f 00 00       	call   80103c7a <acquire>
  if(f->ref < 1)
80100d1b:	8b 43 04             	mov    0x4(%ebx),%eax
80100d1e:	83 c4 10             	add    $0x10,%esp
80100d21:	85 c0                	test   %eax,%eax
80100d23:	7e 1f                	jle    80100d44 <fileclose+0x3d>
    panic("fileclose");
  if(--f->ref > 0){
80100d25:	83 e8 01             	sub    $0x1,%eax
80100d28:	89 43 04             	mov    %eax,0x4(%ebx)
80100d2b:	85 c0                	test   %eax,%eax
80100d2d:	7e 22                	jle    80100d51 <fileclose+0x4a>
    release(&ftable.lock);
80100d2f:	83 ec 0c             	sub    $0xc,%esp
80100d32:	68 20 10 11 80       	push   $0x80111020
80100d37:	e8 a3 2f 00 00       	call   80103cdf <release>
    return;
80100d3c:	83 c4 10             	add    $0x10,%esp
  else if(ff.type == FD_INODE){
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
80100d3f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100d42:	c9                   	leave  
80100d43:	c3                   	ret    
    panic("fileclose");
80100d44:	83 ec 0c             	sub    $0xc,%esp
80100d47:	68 84 65 10 80       	push   $0x80106584
80100d4c:	e8 f7 f5 ff ff       	call   80100348 <panic>
  ff = *f;
80100d51:	8b 03                	mov    (%ebx),%eax
80100d53:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d56:	8b 43 08             	mov    0x8(%ebx),%eax
80100d59:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d5c:	8b 43 0c             	mov    0xc(%ebx),%eax
80100d5f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100d62:	8b 43 10             	mov    0x10(%ebx),%eax
80100d65:	89 45 f0             	mov    %eax,-0x10(%ebp)
  f->ref = 0;
80100d68:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  f->type = FD_NONE;
80100d6f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  release(&ftable.lock);
80100d75:	83 ec 0c             	sub    $0xc,%esp
80100d78:	68 20 10 11 80       	push   $0x80111020
80100d7d:	e8 5d 2f 00 00       	call   80103cdf <release>
  if(ff.type == FD_PIPE)
80100d82:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d85:	83 c4 10             	add    $0x10,%esp
80100d88:	83 f8 01             	cmp    $0x1,%eax
80100d8b:	74 1f                	je     80100dac <fileclose+0xa5>
  else if(ff.type == FD_INODE){
80100d8d:	83 f8 02             	cmp    $0x2,%eax
80100d90:	75 ad                	jne    80100d3f <fileclose+0x38>
    begin_op();
80100d92:	e8 4b 1a 00 00       	call   801027e2 <begin_op>
    iput(ff.ip);
80100d97:	83 ec 0c             	sub    $0xc,%esp
80100d9a:	ff 75 f0             	pushl  -0x10(%ebp)
80100d9d:	e8 1a 09 00 00       	call   801016bc <iput>
    end_op();
80100da2:	e8 b5 1a 00 00       	call   8010285c <end_op>
80100da7:	83 c4 10             	add    $0x10,%esp
80100daa:	eb 93                	jmp    80100d3f <fileclose+0x38>
    pipeclose(ff.pipe, ff.writable);
80100dac:	83 ec 08             	sub    $0x8,%esp
80100daf:	0f be 45 e9          	movsbl -0x17(%ebp),%eax
80100db3:	50                   	push   %eax
80100db4:	ff 75 ec             	pushl  -0x14(%ebp)
80100db7:	e8 9a 20 00 00       	call   80102e56 <pipeclose>
80100dbc:	83 c4 10             	add    $0x10,%esp
80100dbf:	e9 7b ff ff ff       	jmp    80100d3f <fileclose+0x38>

80100dc4 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80100dc4:	55                   	push   %ebp
80100dc5:	89 e5                	mov    %esp,%ebp
80100dc7:	53                   	push   %ebx
80100dc8:	83 ec 04             	sub    $0x4,%esp
80100dcb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(f->type == FD_INODE){
80100dce:	83 3b 02             	cmpl   $0x2,(%ebx)
80100dd1:	75 31                	jne    80100e04 <filestat+0x40>
    ilock(f->ip);
80100dd3:	83 ec 0c             	sub    $0xc,%esp
80100dd6:	ff 73 10             	pushl  0x10(%ebx)
80100dd9:	e8 d7 07 00 00       	call   801015b5 <ilock>
    stati(f->ip, st);
80100dde:	83 c4 08             	add    $0x8,%esp
80100de1:	ff 75 0c             	pushl  0xc(%ebp)
80100de4:	ff 73 10             	pushl  0x10(%ebx)
80100de7:	e8 90 09 00 00       	call   8010177c <stati>
    iunlock(f->ip);
80100dec:	83 c4 04             	add    $0x4,%esp
80100def:	ff 73 10             	pushl  0x10(%ebx)
80100df2:	e8 80 08 00 00       	call   80101677 <iunlock>
    return 0;
80100df7:	83 c4 10             	add    $0x10,%esp
80100dfa:	b8 00 00 00 00       	mov    $0x0,%eax
  }
  return -1;
}
80100dff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100e02:	c9                   	leave  
80100e03:	c3                   	ret    
  return -1;
80100e04:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100e09:	eb f4                	jmp    80100dff <filestat+0x3b>

80100e0b <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80100e0b:	55                   	push   %ebp
80100e0c:	89 e5                	mov    %esp,%ebp
80100e0e:	56                   	push   %esi
80100e0f:	53                   	push   %ebx
80100e10:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;

  if(f->readable == 0)
80100e13:	80 7b 08 00          	cmpb   $0x0,0x8(%ebx)
80100e17:	74 70                	je     80100e89 <fileread+0x7e>
    return -1;
  if(f->type == FD_PIPE)
80100e19:	8b 03                	mov    (%ebx),%eax
80100e1b:	83 f8 01             	cmp    $0x1,%eax
80100e1e:	74 44                	je     80100e64 <fileread+0x59>
    return piperead(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100e20:	83 f8 02             	cmp    $0x2,%eax
80100e23:	75 57                	jne    80100e7c <fileread+0x71>
    ilock(f->ip);
80100e25:	83 ec 0c             	sub    $0xc,%esp
80100e28:	ff 73 10             	pushl  0x10(%ebx)
80100e2b:	e8 85 07 00 00       	call   801015b5 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80100e30:	ff 75 10             	pushl  0x10(%ebp)
80100e33:	ff 73 14             	pushl  0x14(%ebx)
80100e36:	ff 75 0c             	pushl  0xc(%ebp)
80100e39:	ff 73 10             	pushl  0x10(%ebx)
80100e3c:	e8 66 09 00 00       	call   801017a7 <readi>
80100e41:	89 c6                	mov    %eax,%esi
80100e43:	83 c4 20             	add    $0x20,%esp
80100e46:	85 c0                	test   %eax,%eax
80100e48:	7e 03                	jle    80100e4d <fileread+0x42>
      f->off += r;
80100e4a:	01 43 14             	add    %eax,0x14(%ebx)
    iunlock(f->ip);
80100e4d:	83 ec 0c             	sub    $0xc,%esp
80100e50:	ff 73 10             	pushl  0x10(%ebx)
80100e53:	e8 1f 08 00 00       	call   80101677 <iunlock>
    return r;
80100e58:	83 c4 10             	add    $0x10,%esp
  }
  panic("fileread");
}
80100e5b:	89 f0                	mov    %esi,%eax
80100e5d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100e60:	5b                   	pop    %ebx
80100e61:	5e                   	pop    %esi
80100e62:	5d                   	pop    %ebp
80100e63:	c3                   	ret    
    return piperead(f->pipe, addr, n);
80100e64:	83 ec 04             	sub    $0x4,%esp
80100e67:	ff 75 10             	pushl  0x10(%ebp)
80100e6a:	ff 75 0c             	pushl  0xc(%ebp)
80100e6d:	ff 73 0c             	pushl  0xc(%ebx)
80100e70:	e8 39 21 00 00       	call   80102fae <piperead>
80100e75:	89 c6                	mov    %eax,%esi
80100e77:	83 c4 10             	add    $0x10,%esp
80100e7a:	eb df                	jmp    80100e5b <fileread+0x50>
  panic("fileread");
80100e7c:	83 ec 0c             	sub    $0xc,%esp
80100e7f:	68 8e 65 10 80       	push   $0x8010658e
80100e84:	e8 bf f4 ff ff       	call   80100348 <panic>
    return -1;
80100e89:	be ff ff ff ff       	mov    $0xffffffff,%esi
80100e8e:	eb cb                	jmp    80100e5b <fileread+0x50>

80100e90 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80100e90:	55                   	push   %ebp
80100e91:	89 e5                	mov    %esp,%ebp
80100e93:	57                   	push   %edi
80100e94:	56                   	push   %esi
80100e95:	53                   	push   %ebx
80100e96:	83 ec 1c             	sub    $0x1c,%esp
80100e99:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;

  if(f->writable == 0)
80100e9c:	80 7b 09 00          	cmpb   $0x0,0x9(%ebx)
80100ea0:	0f 84 c5 00 00 00    	je     80100f6b <filewrite+0xdb>
    return -1;
  if(f->type == FD_PIPE)
80100ea6:	8b 03                	mov    (%ebx),%eax
80100ea8:	83 f8 01             	cmp    $0x1,%eax
80100eab:	74 10                	je     80100ebd <filewrite+0x2d>
    return pipewrite(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100ead:	83 f8 02             	cmp    $0x2,%eax
80100eb0:	0f 85 a8 00 00 00    	jne    80100f5e <filewrite+0xce>
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
    int i = 0;
80100eb6:	bf 00 00 00 00       	mov    $0x0,%edi
80100ebb:	eb 67                	jmp    80100f24 <filewrite+0x94>
    return pipewrite(f->pipe, addr, n);
80100ebd:	83 ec 04             	sub    $0x4,%esp
80100ec0:	ff 75 10             	pushl  0x10(%ebp)
80100ec3:	ff 75 0c             	pushl  0xc(%ebp)
80100ec6:	ff 73 0c             	pushl  0xc(%ebx)
80100ec9:	e8 14 20 00 00       	call   80102ee2 <pipewrite>
80100ece:	83 c4 10             	add    $0x10,%esp
80100ed1:	e9 80 00 00 00       	jmp    80100f56 <filewrite+0xc6>
    while(i < n){
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
80100ed6:	e8 07 19 00 00       	call   801027e2 <begin_op>
      ilock(f->ip);
80100edb:	83 ec 0c             	sub    $0xc,%esp
80100ede:	ff 73 10             	pushl  0x10(%ebx)
80100ee1:	e8 cf 06 00 00       	call   801015b5 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80100ee6:	89 f8                	mov    %edi,%eax
80100ee8:	03 45 0c             	add    0xc(%ebp),%eax
80100eeb:	ff 75 e4             	pushl  -0x1c(%ebp)
80100eee:	ff 73 14             	pushl  0x14(%ebx)
80100ef1:	50                   	push   %eax
80100ef2:	ff 73 10             	pushl  0x10(%ebx)
80100ef5:	e8 aa 09 00 00       	call   801018a4 <writei>
80100efa:	89 c6                	mov    %eax,%esi
80100efc:	83 c4 20             	add    $0x20,%esp
80100eff:	85 c0                	test   %eax,%eax
80100f01:	7e 03                	jle    80100f06 <filewrite+0x76>
        f->off += r;
80100f03:	01 43 14             	add    %eax,0x14(%ebx)
      iunlock(f->ip);
80100f06:	83 ec 0c             	sub    $0xc,%esp
80100f09:	ff 73 10             	pushl  0x10(%ebx)
80100f0c:	e8 66 07 00 00       	call   80101677 <iunlock>
      end_op();
80100f11:	e8 46 19 00 00       	call   8010285c <end_op>

      if(r < 0)
80100f16:	83 c4 10             	add    $0x10,%esp
80100f19:	85 f6                	test   %esi,%esi
80100f1b:	78 31                	js     80100f4e <filewrite+0xbe>
        break;
      if(r != n1)
80100f1d:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
80100f20:	75 1f                	jne    80100f41 <filewrite+0xb1>
        panic("short filewrite");
      i += r;
80100f22:	01 f7                	add    %esi,%edi
    while(i < n){
80100f24:	3b 7d 10             	cmp    0x10(%ebp),%edi
80100f27:	7d 25                	jge    80100f4e <filewrite+0xbe>
      int n1 = n - i;
80100f29:	8b 45 10             	mov    0x10(%ebp),%eax
80100f2c:	29 f8                	sub    %edi,%eax
80100f2e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(n1 > max)
80100f31:	3d 00 06 00 00       	cmp    $0x600,%eax
80100f36:	7e 9e                	jle    80100ed6 <filewrite+0x46>
        n1 = max;
80100f38:	c7 45 e4 00 06 00 00 	movl   $0x600,-0x1c(%ebp)
80100f3f:	eb 95                	jmp    80100ed6 <filewrite+0x46>
        panic("short filewrite");
80100f41:	83 ec 0c             	sub    $0xc,%esp
80100f44:	68 97 65 10 80       	push   $0x80106597
80100f49:	e8 fa f3 ff ff       	call   80100348 <panic>
    }
    return i == n ? n : -1;
80100f4e:	3b 7d 10             	cmp    0x10(%ebp),%edi
80100f51:	75 1f                	jne    80100f72 <filewrite+0xe2>
80100f53:	8b 45 10             	mov    0x10(%ebp),%eax
  }
  panic("filewrite");
}
80100f56:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100f59:	5b                   	pop    %ebx
80100f5a:	5e                   	pop    %esi
80100f5b:	5f                   	pop    %edi
80100f5c:	5d                   	pop    %ebp
80100f5d:	c3                   	ret    
  panic("filewrite");
80100f5e:	83 ec 0c             	sub    $0xc,%esp
80100f61:	68 9d 65 10 80       	push   $0x8010659d
80100f66:	e8 dd f3 ff ff       	call   80100348 <panic>
    return -1;
80100f6b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100f70:	eb e4                	jmp    80100f56 <filewrite+0xc6>
    return i == n ? n : -1;
80100f72:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100f77:	eb dd                	jmp    80100f56 <filewrite+0xc6>

80100f79 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80100f79:	55                   	push   %ebp
80100f7a:	89 e5                	mov    %esp,%ebp
80100f7c:	57                   	push   %edi
80100f7d:	56                   	push   %esi
80100f7e:	53                   	push   %ebx
80100f7f:	83 ec 0c             	sub    $0xc,%esp
80100f82:	89 d7                	mov    %edx,%edi
  char *s;
  int len;

  while(*path == '/')
80100f84:	eb 03                	jmp    80100f89 <skipelem+0x10>
    path++;
80100f86:	83 c0 01             	add    $0x1,%eax
  while(*path == '/')
80100f89:	0f b6 10             	movzbl (%eax),%edx
80100f8c:	80 fa 2f             	cmp    $0x2f,%dl
80100f8f:	74 f5                	je     80100f86 <skipelem+0xd>
  if(*path == 0)
80100f91:	84 d2                	test   %dl,%dl
80100f93:	74 59                	je     80100fee <skipelem+0x75>
80100f95:	89 c3                	mov    %eax,%ebx
80100f97:	eb 03                	jmp    80100f9c <skipelem+0x23>
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
    path++;
80100f99:	83 c3 01             	add    $0x1,%ebx
  while(*path != '/' && *path != 0)
80100f9c:	0f b6 13             	movzbl (%ebx),%edx
80100f9f:	80 fa 2f             	cmp    $0x2f,%dl
80100fa2:	0f 95 c1             	setne  %cl
80100fa5:	84 d2                	test   %dl,%dl
80100fa7:	0f 95 c2             	setne  %dl
80100faa:	84 d1                	test   %dl,%cl
80100fac:	75 eb                	jne    80100f99 <skipelem+0x20>
  len = path - s;
80100fae:	89 de                	mov    %ebx,%esi
80100fb0:	29 c6                	sub    %eax,%esi
  if(len >= DIRSIZ)
80100fb2:	83 fe 0d             	cmp    $0xd,%esi
80100fb5:	7e 11                	jle    80100fc8 <skipelem+0x4f>
    memmove(name, s, DIRSIZ);
80100fb7:	83 ec 04             	sub    $0x4,%esp
80100fba:	6a 0e                	push   $0xe
80100fbc:	50                   	push   %eax
80100fbd:	57                   	push   %edi
80100fbe:	e8 de 2d 00 00       	call   80103da1 <memmove>
80100fc3:	83 c4 10             	add    $0x10,%esp
80100fc6:	eb 17                	jmp    80100fdf <skipelem+0x66>
  else {
    memmove(name, s, len);
80100fc8:	83 ec 04             	sub    $0x4,%esp
80100fcb:	56                   	push   %esi
80100fcc:	50                   	push   %eax
80100fcd:	57                   	push   %edi
80100fce:	e8 ce 2d 00 00       	call   80103da1 <memmove>
    name[len] = 0;
80100fd3:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
80100fd7:	83 c4 10             	add    $0x10,%esp
80100fda:	eb 03                	jmp    80100fdf <skipelem+0x66>
  }
  while(*path == '/')
    path++;
80100fdc:	83 c3 01             	add    $0x1,%ebx
  while(*path == '/')
80100fdf:	80 3b 2f             	cmpb   $0x2f,(%ebx)
80100fe2:	74 f8                	je     80100fdc <skipelem+0x63>
  return path;
}
80100fe4:	89 d8                	mov    %ebx,%eax
80100fe6:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100fe9:	5b                   	pop    %ebx
80100fea:	5e                   	pop    %esi
80100feb:	5f                   	pop    %edi
80100fec:	5d                   	pop    %ebp
80100fed:	c3                   	ret    
    return 0;
80100fee:	bb 00 00 00 00       	mov    $0x0,%ebx
80100ff3:	eb ef                	jmp    80100fe4 <skipelem+0x6b>

80100ff5 <bzero>:
{
80100ff5:	55                   	push   %ebp
80100ff6:	89 e5                	mov    %esp,%ebp
80100ff8:	53                   	push   %ebx
80100ff9:	83 ec 0c             	sub    $0xc,%esp
  bp = bread(dev, bno);
80100ffc:	52                   	push   %edx
80100ffd:	50                   	push   %eax
80100ffe:	e8 69 f1 ff ff       	call   8010016c <bread>
80101003:	89 c3                	mov    %eax,%ebx
  memset(bp->data, 0, BSIZE);
80101005:	8d 40 5c             	lea    0x5c(%eax),%eax
80101008:	83 c4 0c             	add    $0xc,%esp
8010100b:	68 00 02 00 00       	push   $0x200
80101010:	6a 00                	push   $0x0
80101012:	50                   	push   %eax
80101013:	e8 0e 2d 00 00       	call   80103d26 <memset>
  log_write(bp);
80101018:	89 1c 24             	mov    %ebx,(%esp)
8010101b:	e8 eb 18 00 00       	call   8010290b <log_write>
  brelse(bp);
80101020:	89 1c 24             	mov    %ebx,(%esp)
80101023:	e8 ad f1 ff ff       	call   801001d5 <brelse>
}
80101028:	83 c4 10             	add    $0x10,%esp
8010102b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010102e:	c9                   	leave  
8010102f:	c3                   	ret    

80101030 <balloc>:
{
80101030:	55                   	push   %ebp
80101031:	89 e5                	mov    %esp,%ebp
80101033:	57                   	push   %edi
80101034:	56                   	push   %esi
80101035:	53                   	push   %ebx
80101036:	83 ec 1c             	sub    $0x1c,%esp
80101039:	89 45 d8             	mov    %eax,-0x28(%ebp)
  for(b = 0; b < sb.size; b += BPB){
8010103c:	be 00 00 00 00       	mov    $0x0,%esi
80101041:	eb 14                	jmp    80101057 <balloc+0x27>
    brelse(bp);
80101043:	83 ec 0c             	sub    $0xc,%esp
80101046:	ff 75 e4             	pushl  -0x1c(%ebp)
80101049:	e8 87 f1 ff ff       	call   801001d5 <brelse>
  for(b = 0; b < sb.size; b += BPB){
8010104e:	81 c6 00 10 00 00    	add    $0x1000,%esi
80101054:	83 c4 10             	add    $0x10,%esp
80101057:	39 35 20 1a 11 80    	cmp    %esi,0x80111a20
8010105d:	76 75                	jbe    801010d4 <balloc+0xa4>
    bp = bread(dev, BBLOCK(b, sb));
8010105f:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
80101065:	85 f6                	test   %esi,%esi
80101067:	0f 49 c6             	cmovns %esi,%eax
8010106a:	c1 f8 0c             	sar    $0xc,%eax
8010106d:	03 05 38 1a 11 80    	add    0x80111a38,%eax
80101073:	83 ec 08             	sub    $0x8,%esp
80101076:	50                   	push   %eax
80101077:	ff 75 d8             	pushl  -0x28(%ebp)
8010107a:	e8 ed f0 ff ff       	call   8010016c <bread>
8010107f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101082:	83 c4 10             	add    $0x10,%esp
80101085:	b8 00 00 00 00       	mov    $0x0,%eax
8010108a:	3d ff 0f 00 00       	cmp    $0xfff,%eax
8010108f:	7f b2                	jg     80101043 <balloc+0x13>
80101091:	8d 1c 06             	lea    (%esi,%eax,1),%ebx
80101094:	89 5d e0             	mov    %ebx,-0x20(%ebp)
80101097:	3b 1d 20 1a 11 80    	cmp    0x80111a20,%ebx
8010109d:	73 a4                	jae    80101043 <balloc+0x13>
      m = 1 << (bi % 8);
8010109f:	99                   	cltd   
801010a0:	c1 ea 1d             	shr    $0x1d,%edx
801010a3:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
801010a6:	83 e1 07             	and    $0x7,%ecx
801010a9:	29 d1                	sub    %edx,%ecx
801010ab:	ba 01 00 00 00       	mov    $0x1,%edx
801010b0:	d3 e2                	shl    %cl,%edx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801010b2:	8d 48 07             	lea    0x7(%eax),%ecx
801010b5:	85 c0                	test   %eax,%eax
801010b7:	0f 49 c8             	cmovns %eax,%ecx
801010ba:	c1 f9 03             	sar    $0x3,%ecx
801010bd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
801010c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
801010c3:	0f b6 4c 0f 5c       	movzbl 0x5c(%edi,%ecx,1),%ecx
801010c8:	0f b6 f9             	movzbl %cl,%edi
801010cb:	85 d7                	test   %edx,%edi
801010cd:	74 12                	je     801010e1 <balloc+0xb1>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801010cf:	83 c0 01             	add    $0x1,%eax
801010d2:	eb b6                	jmp    8010108a <balloc+0x5a>
  panic("balloc: out of blocks");
801010d4:	83 ec 0c             	sub    $0xc,%esp
801010d7:	68 a7 65 10 80       	push   $0x801065a7
801010dc:	e8 67 f2 ff ff       	call   80100348 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
801010e1:	09 ca                	or     %ecx,%edx
801010e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010e6:	8b 75 dc             	mov    -0x24(%ebp),%esi
801010e9:	88 54 30 5c          	mov    %dl,0x5c(%eax,%esi,1)
        log_write(bp);
801010ed:	83 ec 0c             	sub    $0xc,%esp
801010f0:	89 c6                	mov    %eax,%esi
801010f2:	50                   	push   %eax
801010f3:	e8 13 18 00 00       	call   8010290b <log_write>
        brelse(bp);
801010f8:	89 34 24             	mov    %esi,(%esp)
801010fb:	e8 d5 f0 ff ff       	call   801001d5 <brelse>
        bzero(dev, b + bi);
80101100:	89 da                	mov    %ebx,%edx
80101102:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101105:	e8 eb fe ff ff       	call   80100ff5 <bzero>
}
8010110a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010110d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101110:	5b                   	pop    %ebx
80101111:	5e                   	pop    %esi
80101112:	5f                   	pop    %edi
80101113:	5d                   	pop    %ebp
80101114:	c3                   	ret    

80101115 <bmap>:
{
80101115:	55                   	push   %ebp
80101116:	89 e5                	mov    %esp,%ebp
80101118:	57                   	push   %edi
80101119:	56                   	push   %esi
8010111a:	53                   	push   %ebx
8010111b:	83 ec 1c             	sub    $0x1c,%esp
8010111e:	89 c6                	mov    %eax,%esi
80101120:	89 d7                	mov    %edx,%edi
  if(bn < NDIRECT){
80101122:	83 fa 0b             	cmp    $0xb,%edx
80101125:	77 17                	ja     8010113e <bmap+0x29>
    if((addr = ip->addrs[bn]) == 0)
80101127:	8b 5c 90 5c          	mov    0x5c(%eax,%edx,4),%ebx
8010112b:	85 db                	test   %ebx,%ebx
8010112d:	75 4a                	jne    80101179 <bmap+0x64>
      ip->addrs[bn] = addr = balloc(ip->dev);
8010112f:	8b 00                	mov    (%eax),%eax
80101131:	e8 fa fe ff ff       	call   80101030 <balloc>
80101136:	89 c3                	mov    %eax,%ebx
80101138:	89 44 be 5c          	mov    %eax,0x5c(%esi,%edi,4)
8010113c:	eb 3b                	jmp    80101179 <bmap+0x64>
  bn -= NDIRECT;
8010113e:	8d 5a f4             	lea    -0xc(%edx),%ebx
  if(bn < NINDIRECT){
80101141:	83 fb 7f             	cmp    $0x7f,%ebx
80101144:	77 68                	ja     801011ae <bmap+0x99>
    if((addr = ip->addrs[NDIRECT]) == 0)
80101146:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
8010114c:	85 c0                	test   %eax,%eax
8010114e:	74 33                	je     80101183 <bmap+0x6e>
    bp = bread(ip->dev, addr);
80101150:	83 ec 08             	sub    $0x8,%esp
80101153:	50                   	push   %eax
80101154:	ff 36                	pushl  (%esi)
80101156:	e8 11 f0 ff ff       	call   8010016c <bread>
8010115b:	89 c7                	mov    %eax,%edi
    if((addr = a[bn]) == 0){
8010115d:	8d 44 98 5c          	lea    0x5c(%eax,%ebx,4),%eax
80101161:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101164:	8b 18                	mov    (%eax),%ebx
80101166:	83 c4 10             	add    $0x10,%esp
80101169:	85 db                	test   %ebx,%ebx
8010116b:	74 25                	je     80101192 <bmap+0x7d>
    brelse(bp);
8010116d:	83 ec 0c             	sub    $0xc,%esp
80101170:	57                   	push   %edi
80101171:	e8 5f f0 ff ff       	call   801001d5 <brelse>
    return addr;
80101176:	83 c4 10             	add    $0x10,%esp
}
80101179:	89 d8                	mov    %ebx,%eax
8010117b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010117e:	5b                   	pop    %ebx
8010117f:	5e                   	pop    %esi
80101180:	5f                   	pop    %edi
80101181:	5d                   	pop    %ebp
80101182:	c3                   	ret    
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101183:	8b 06                	mov    (%esi),%eax
80101185:	e8 a6 fe ff ff       	call   80101030 <balloc>
8010118a:	89 86 8c 00 00 00    	mov    %eax,0x8c(%esi)
80101190:	eb be                	jmp    80101150 <bmap+0x3b>
      a[bn] = addr = balloc(ip->dev);
80101192:	8b 06                	mov    (%esi),%eax
80101194:	e8 97 fe ff ff       	call   80101030 <balloc>
80101199:	89 c3                	mov    %eax,%ebx
8010119b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010119e:	89 18                	mov    %ebx,(%eax)
      log_write(bp);
801011a0:	83 ec 0c             	sub    $0xc,%esp
801011a3:	57                   	push   %edi
801011a4:	e8 62 17 00 00       	call   8010290b <log_write>
801011a9:	83 c4 10             	add    $0x10,%esp
801011ac:	eb bf                	jmp    8010116d <bmap+0x58>
  panic("bmap: out of range");
801011ae:	83 ec 0c             	sub    $0xc,%esp
801011b1:	68 bd 65 10 80       	push   $0x801065bd
801011b6:	e8 8d f1 ff ff       	call   80100348 <panic>

801011bb <iget>:
{
801011bb:	55                   	push   %ebp
801011bc:	89 e5                	mov    %esp,%ebp
801011be:	57                   	push   %edi
801011bf:	56                   	push   %esi
801011c0:	53                   	push   %ebx
801011c1:	83 ec 28             	sub    $0x28,%esp
801011c4:	89 c7                	mov    %eax,%edi
801011c6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  acquire(&icache.lock);
801011c9:	68 40 1a 11 80       	push   $0x80111a40
801011ce:	e8 a7 2a 00 00       	call   80103c7a <acquire>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801011d3:	83 c4 10             	add    $0x10,%esp
  empty = 0;
801011d6:	be 00 00 00 00       	mov    $0x0,%esi
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801011db:	bb 74 1a 11 80       	mov    $0x80111a74,%ebx
801011e0:	eb 0a                	jmp    801011ec <iget+0x31>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801011e2:	85 f6                	test   %esi,%esi
801011e4:	74 3b                	je     80101221 <iget+0x66>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801011e6:	81 c3 90 00 00 00    	add    $0x90,%ebx
801011ec:	81 fb 94 36 11 80    	cmp    $0x80113694,%ebx
801011f2:	73 35                	jae    80101229 <iget+0x6e>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801011f4:	8b 43 08             	mov    0x8(%ebx),%eax
801011f7:	85 c0                	test   %eax,%eax
801011f9:	7e e7                	jle    801011e2 <iget+0x27>
801011fb:	39 3b                	cmp    %edi,(%ebx)
801011fd:	75 e3                	jne    801011e2 <iget+0x27>
801011ff:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80101202:	39 4b 04             	cmp    %ecx,0x4(%ebx)
80101205:	75 db                	jne    801011e2 <iget+0x27>
      ip->ref++;
80101207:	83 c0 01             	add    $0x1,%eax
8010120a:	89 43 08             	mov    %eax,0x8(%ebx)
      release(&icache.lock);
8010120d:	83 ec 0c             	sub    $0xc,%esp
80101210:	68 40 1a 11 80       	push   $0x80111a40
80101215:	e8 c5 2a 00 00       	call   80103cdf <release>
      return ip;
8010121a:	83 c4 10             	add    $0x10,%esp
8010121d:	89 de                	mov    %ebx,%esi
8010121f:	eb 32                	jmp    80101253 <iget+0x98>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101221:	85 c0                	test   %eax,%eax
80101223:	75 c1                	jne    801011e6 <iget+0x2b>
      empty = ip;
80101225:	89 de                	mov    %ebx,%esi
80101227:	eb bd                	jmp    801011e6 <iget+0x2b>
  if(empty == 0)
80101229:	85 f6                	test   %esi,%esi
8010122b:	74 30                	je     8010125d <iget+0xa2>
  ip->dev = dev;
8010122d:	89 3e                	mov    %edi,(%esi)
  ip->inum = inum;
8010122f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101232:	89 46 04             	mov    %eax,0x4(%esi)
  ip->ref = 1;
80101235:	c7 46 08 01 00 00 00 	movl   $0x1,0x8(%esi)
  ip->valid = 0;
8010123c:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
  release(&icache.lock);
80101243:	83 ec 0c             	sub    $0xc,%esp
80101246:	68 40 1a 11 80       	push   $0x80111a40
8010124b:	e8 8f 2a 00 00       	call   80103cdf <release>
  return ip;
80101250:	83 c4 10             	add    $0x10,%esp
}
80101253:	89 f0                	mov    %esi,%eax
80101255:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101258:	5b                   	pop    %ebx
80101259:	5e                   	pop    %esi
8010125a:	5f                   	pop    %edi
8010125b:	5d                   	pop    %ebp
8010125c:	c3                   	ret    
    panic("iget: no inodes");
8010125d:	83 ec 0c             	sub    $0xc,%esp
80101260:	68 d0 65 10 80       	push   $0x801065d0
80101265:	e8 de f0 ff ff       	call   80100348 <panic>

8010126a <readsb>:
{
8010126a:	55                   	push   %ebp
8010126b:	89 e5                	mov    %esp,%ebp
8010126d:	53                   	push   %ebx
8010126e:	83 ec 0c             	sub    $0xc,%esp
  bp = bread(dev, 1);
80101271:	6a 01                	push   $0x1
80101273:	ff 75 08             	pushl  0x8(%ebp)
80101276:	e8 f1 ee ff ff       	call   8010016c <bread>
8010127b:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
8010127d:	8d 40 5c             	lea    0x5c(%eax),%eax
80101280:	83 c4 0c             	add    $0xc,%esp
80101283:	6a 1c                	push   $0x1c
80101285:	50                   	push   %eax
80101286:	ff 75 0c             	pushl  0xc(%ebp)
80101289:	e8 13 2b 00 00       	call   80103da1 <memmove>
  brelse(bp);
8010128e:	89 1c 24             	mov    %ebx,(%esp)
80101291:	e8 3f ef ff ff       	call   801001d5 <brelse>
}
80101296:	83 c4 10             	add    $0x10,%esp
80101299:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010129c:	c9                   	leave  
8010129d:	c3                   	ret    

8010129e <bfree>:
{
8010129e:	55                   	push   %ebp
8010129f:	89 e5                	mov    %esp,%ebp
801012a1:	56                   	push   %esi
801012a2:	53                   	push   %ebx
801012a3:	89 c6                	mov    %eax,%esi
801012a5:	89 d3                	mov    %edx,%ebx
  readsb(dev, &sb);
801012a7:	83 ec 08             	sub    $0x8,%esp
801012aa:	68 20 1a 11 80       	push   $0x80111a20
801012af:	50                   	push   %eax
801012b0:	e8 b5 ff ff ff       	call   8010126a <readsb>
  bp = bread(dev, BBLOCK(b, sb));
801012b5:	89 d8                	mov    %ebx,%eax
801012b7:	c1 e8 0c             	shr    $0xc,%eax
801012ba:	03 05 38 1a 11 80    	add    0x80111a38,%eax
801012c0:	83 c4 08             	add    $0x8,%esp
801012c3:	50                   	push   %eax
801012c4:	56                   	push   %esi
801012c5:	e8 a2 ee ff ff       	call   8010016c <bread>
801012ca:	89 c6                	mov    %eax,%esi
  m = 1 << (bi % 8);
801012cc:	89 d9                	mov    %ebx,%ecx
801012ce:	83 e1 07             	and    $0x7,%ecx
801012d1:	b8 01 00 00 00       	mov    $0x1,%eax
801012d6:	d3 e0                	shl    %cl,%eax
  if((bp->data[bi/8] & m) == 0)
801012d8:	83 c4 10             	add    $0x10,%esp
801012db:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
801012e1:	c1 fb 03             	sar    $0x3,%ebx
801012e4:	0f b6 54 1e 5c       	movzbl 0x5c(%esi,%ebx,1),%edx
801012e9:	0f b6 ca             	movzbl %dl,%ecx
801012ec:	85 c1                	test   %eax,%ecx
801012ee:	74 23                	je     80101313 <bfree+0x75>
  bp->data[bi/8] &= ~m;
801012f0:	f7 d0                	not    %eax
801012f2:	21 d0                	and    %edx,%eax
801012f4:	88 44 1e 5c          	mov    %al,0x5c(%esi,%ebx,1)
  log_write(bp);
801012f8:	83 ec 0c             	sub    $0xc,%esp
801012fb:	56                   	push   %esi
801012fc:	e8 0a 16 00 00       	call   8010290b <log_write>
  brelse(bp);
80101301:	89 34 24             	mov    %esi,(%esp)
80101304:	e8 cc ee ff ff       	call   801001d5 <brelse>
}
80101309:	83 c4 10             	add    $0x10,%esp
8010130c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010130f:	5b                   	pop    %ebx
80101310:	5e                   	pop    %esi
80101311:	5d                   	pop    %ebp
80101312:	c3                   	ret    
    panic("freeing free block");
80101313:	83 ec 0c             	sub    $0xc,%esp
80101316:	68 e0 65 10 80       	push   $0x801065e0
8010131b:	e8 28 f0 ff ff       	call   80100348 <panic>

80101320 <iinit>:
{
80101320:	55                   	push   %ebp
80101321:	89 e5                	mov    %esp,%ebp
80101323:	53                   	push   %ebx
80101324:	83 ec 0c             	sub    $0xc,%esp
  initlock(&icache.lock, "icache");
80101327:	68 f3 65 10 80       	push   $0x801065f3
8010132c:	68 40 1a 11 80       	push   $0x80111a40
80101331:	e8 08 28 00 00       	call   80103b3e <initlock>
  for(i = 0; i < NINODE; i++) {
80101336:	83 c4 10             	add    $0x10,%esp
80101339:	bb 00 00 00 00       	mov    $0x0,%ebx
8010133e:	eb 21                	jmp    80101361 <iinit+0x41>
    initsleeplock(&icache.inode[i].lock, "inode");
80101340:	83 ec 08             	sub    $0x8,%esp
80101343:	68 fa 65 10 80       	push   $0x801065fa
80101348:	8d 14 db             	lea    (%ebx,%ebx,8),%edx
8010134b:	89 d0                	mov    %edx,%eax
8010134d:	c1 e0 04             	shl    $0x4,%eax
80101350:	05 80 1a 11 80       	add    $0x80111a80,%eax
80101355:	50                   	push   %eax
80101356:	e8 ff 26 00 00       	call   80103a5a <initsleeplock>
  for(i = 0; i < NINODE; i++) {
8010135b:	83 c3 01             	add    $0x1,%ebx
8010135e:	83 c4 10             	add    $0x10,%esp
80101361:	83 fb 31             	cmp    $0x31,%ebx
80101364:	7e da                	jle    80101340 <iinit+0x20>
  readsb(dev, &sb);
80101366:	83 ec 08             	sub    $0x8,%esp
80101369:	68 20 1a 11 80       	push   $0x80111a20
8010136e:	ff 75 08             	pushl  0x8(%ebp)
80101371:	e8 f4 fe ff ff       	call   8010126a <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
80101376:	ff 35 38 1a 11 80    	pushl  0x80111a38
8010137c:	ff 35 34 1a 11 80    	pushl  0x80111a34
80101382:	ff 35 30 1a 11 80    	pushl  0x80111a30
80101388:	ff 35 2c 1a 11 80    	pushl  0x80111a2c
8010138e:	ff 35 28 1a 11 80    	pushl  0x80111a28
80101394:	ff 35 24 1a 11 80    	pushl  0x80111a24
8010139a:	ff 35 20 1a 11 80    	pushl  0x80111a20
801013a0:	68 60 66 10 80       	push   $0x80106660
801013a5:	e8 61 f2 ff ff       	call   8010060b <cprintf>
}
801013aa:	83 c4 30             	add    $0x30,%esp
801013ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801013b0:	c9                   	leave  
801013b1:	c3                   	ret    

801013b2 <ialloc>:
{
801013b2:	55                   	push   %ebp
801013b3:	89 e5                	mov    %esp,%ebp
801013b5:	57                   	push   %edi
801013b6:	56                   	push   %esi
801013b7:	53                   	push   %ebx
801013b8:	83 ec 1c             	sub    $0x1c,%esp
801013bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801013be:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(inum = 1; inum < sb.ninodes; inum++){
801013c1:	bb 01 00 00 00       	mov    $0x1,%ebx
801013c6:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
801013c9:	39 1d 28 1a 11 80    	cmp    %ebx,0x80111a28
801013cf:	76 3f                	jbe    80101410 <ialloc+0x5e>
    bp = bread(dev, IBLOCK(inum, sb));
801013d1:	89 d8                	mov    %ebx,%eax
801013d3:	c1 e8 03             	shr    $0x3,%eax
801013d6:	03 05 34 1a 11 80    	add    0x80111a34,%eax
801013dc:	83 ec 08             	sub    $0x8,%esp
801013df:	50                   	push   %eax
801013e0:	ff 75 08             	pushl  0x8(%ebp)
801013e3:	e8 84 ed ff ff       	call   8010016c <bread>
801013e8:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + inum%IPB;
801013ea:	89 d8                	mov    %ebx,%eax
801013ec:	83 e0 07             	and    $0x7,%eax
801013ef:	c1 e0 06             	shl    $0x6,%eax
801013f2:	8d 7c 06 5c          	lea    0x5c(%esi,%eax,1),%edi
    if(dip->type == 0){  // a free inode
801013f6:	83 c4 10             	add    $0x10,%esp
801013f9:	66 83 3f 00          	cmpw   $0x0,(%edi)
801013fd:	74 1e                	je     8010141d <ialloc+0x6b>
    brelse(bp);
801013ff:	83 ec 0c             	sub    $0xc,%esp
80101402:	56                   	push   %esi
80101403:	e8 cd ed ff ff       	call   801001d5 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
80101408:	83 c3 01             	add    $0x1,%ebx
8010140b:	83 c4 10             	add    $0x10,%esp
8010140e:	eb b6                	jmp    801013c6 <ialloc+0x14>
  panic("ialloc: no inodes");
80101410:	83 ec 0c             	sub    $0xc,%esp
80101413:	68 00 66 10 80       	push   $0x80106600
80101418:	e8 2b ef ff ff       	call   80100348 <panic>
      memset(dip, 0, sizeof(*dip));
8010141d:	83 ec 04             	sub    $0x4,%esp
80101420:	6a 40                	push   $0x40
80101422:	6a 00                	push   $0x0
80101424:	57                   	push   %edi
80101425:	e8 fc 28 00 00       	call   80103d26 <memset>
      dip->type = type;
8010142a:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010142e:	66 89 07             	mov    %ax,(%edi)
      log_write(bp);   // mark it allocated on the disk
80101431:	89 34 24             	mov    %esi,(%esp)
80101434:	e8 d2 14 00 00       	call   8010290b <log_write>
      brelse(bp);
80101439:	89 34 24             	mov    %esi,(%esp)
8010143c:	e8 94 ed ff ff       	call   801001d5 <brelse>
      return iget(dev, inum);
80101441:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101444:	8b 45 08             	mov    0x8(%ebp),%eax
80101447:	e8 6f fd ff ff       	call   801011bb <iget>
}
8010144c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010144f:	5b                   	pop    %ebx
80101450:	5e                   	pop    %esi
80101451:	5f                   	pop    %edi
80101452:	5d                   	pop    %ebp
80101453:	c3                   	ret    

80101454 <iupdate>:
{
80101454:	55                   	push   %ebp
80101455:	89 e5                	mov    %esp,%ebp
80101457:	56                   	push   %esi
80101458:	53                   	push   %ebx
80101459:	8b 5d 08             	mov    0x8(%ebp),%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010145c:	8b 43 04             	mov    0x4(%ebx),%eax
8010145f:	c1 e8 03             	shr    $0x3,%eax
80101462:	03 05 34 1a 11 80    	add    0x80111a34,%eax
80101468:	83 ec 08             	sub    $0x8,%esp
8010146b:	50                   	push   %eax
8010146c:	ff 33                	pushl  (%ebx)
8010146e:	e8 f9 ec ff ff       	call   8010016c <bread>
80101473:	89 c6                	mov    %eax,%esi
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101475:	8b 43 04             	mov    0x4(%ebx),%eax
80101478:	83 e0 07             	and    $0x7,%eax
8010147b:	c1 e0 06             	shl    $0x6,%eax
8010147e:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
  dip->type = ip->type;
80101482:	0f b7 53 50          	movzwl 0x50(%ebx),%edx
80101486:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101489:	0f b7 53 52          	movzwl 0x52(%ebx),%edx
8010148d:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101491:	0f b7 53 54          	movzwl 0x54(%ebx),%edx
80101495:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101499:	0f b7 53 56          	movzwl 0x56(%ebx),%edx
8010149d:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
801014a1:	8b 53 58             	mov    0x58(%ebx),%edx
801014a4:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801014a7:	83 c3 5c             	add    $0x5c,%ebx
801014aa:	83 c0 0c             	add    $0xc,%eax
801014ad:	83 c4 0c             	add    $0xc,%esp
801014b0:	6a 34                	push   $0x34
801014b2:	53                   	push   %ebx
801014b3:	50                   	push   %eax
801014b4:	e8 e8 28 00 00       	call   80103da1 <memmove>
  log_write(bp);
801014b9:	89 34 24             	mov    %esi,(%esp)
801014bc:	e8 4a 14 00 00       	call   8010290b <log_write>
  brelse(bp);
801014c1:	89 34 24             	mov    %esi,(%esp)
801014c4:	e8 0c ed ff ff       	call   801001d5 <brelse>
}
801014c9:	83 c4 10             	add    $0x10,%esp
801014cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
801014cf:	5b                   	pop    %ebx
801014d0:	5e                   	pop    %esi
801014d1:	5d                   	pop    %ebp
801014d2:	c3                   	ret    

801014d3 <itrunc>:
{
801014d3:	55                   	push   %ebp
801014d4:	89 e5                	mov    %esp,%ebp
801014d6:	57                   	push   %edi
801014d7:	56                   	push   %esi
801014d8:	53                   	push   %ebx
801014d9:	83 ec 1c             	sub    $0x1c,%esp
801014dc:	89 c6                	mov    %eax,%esi
  for(i = 0; i < NDIRECT; i++){
801014de:	bb 00 00 00 00       	mov    $0x0,%ebx
801014e3:	eb 03                	jmp    801014e8 <itrunc+0x15>
801014e5:	83 c3 01             	add    $0x1,%ebx
801014e8:	83 fb 0b             	cmp    $0xb,%ebx
801014eb:	7f 19                	jg     80101506 <itrunc+0x33>
    if(ip->addrs[i]){
801014ed:	8b 54 9e 5c          	mov    0x5c(%esi,%ebx,4),%edx
801014f1:	85 d2                	test   %edx,%edx
801014f3:	74 f0                	je     801014e5 <itrunc+0x12>
      bfree(ip->dev, ip->addrs[i]);
801014f5:	8b 06                	mov    (%esi),%eax
801014f7:	e8 a2 fd ff ff       	call   8010129e <bfree>
      ip->addrs[i] = 0;
801014fc:	c7 44 9e 5c 00 00 00 	movl   $0x0,0x5c(%esi,%ebx,4)
80101503:	00 
80101504:	eb df                	jmp    801014e5 <itrunc+0x12>
  if(ip->addrs[NDIRECT]){
80101506:	8b 86 8c 00 00 00    	mov    0x8c(%esi),%eax
8010150c:	85 c0                	test   %eax,%eax
8010150e:	75 1b                	jne    8010152b <itrunc+0x58>
  ip->size = 0;
80101510:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)
  iupdate(ip);
80101517:	83 ec 0c             	sub    $0xc,%esp
8010151a:	56                   	push   %esi
8010151b:	e8 34 ff ff ff       	call   80101454 <iupdate>
}
80101520:	83 c4 10             	add    $0x10,%esp
80101523:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101526:	5b                   	pop    %ebx
80101527:	5e                   	pop    %esi
80101528:	5f                   	pop    %edi
80101529:	5d                   	pop    %ebp
8010152a:	c3                   	ret    
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
8010152b:	83 ec 08             	sub    $0x8,%esp
8010152e:	50                   	push   %eax
8010152f:	ff 36                	pushl  (%esi)
80101531:	e8 36 ec ff ff       	call   8010016c <bread>
80101536:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    a = (uint*)bp->data;
80101539:	8d 78 5c             	lea    0x5c(%eax),%edi
    for(j = 0; j < NINDIRECT; j++){
8010153c:	83 c4 10             	add    $0x10,%esp
8010153f:	bb 00 00 00 00       	mov    $0x0,%ebx
80101544:	eb 03                	jmp    80101549 <itrunc+0x76>
80101546:	83 c3 01             	add    $0x1,%ebx
80101549:	83 fb 7f             	cmp    $0x7f,%ebx
8010154c:	77 10                	ja     8010155e <itrunc+0x8b>
      if(a[j])
8010154e:	8b 14 9f             	mov    (%edi,%ebx,4),%edx
80101551:	85 d2                	test   %edx,%edx
80101553:	74 f1                	je     80101546 <itrunc+0x73>
        bfree(ip->dev, a[j]);
80101555:	8b 06                	mov    (%esi),%eax
80101557:	e8 42 fd ff ff       	call   8010129e <bfree>
8010155c:	eb e8                	jmp    80101546 <itrunc+0x73>
    brelse(bp);
8010155e:	83 ec 0c             	sub    $0xc,%esp
80101561:	ff 75 e4             	pushl  -0x1c(%ebp)
80101564:	e8 6c ec ff ff       	call   801001d5 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101569:	8b 06                	mov    (%esi),%eax
8010156b:	8b 96 8c 00 00 00    	mov    0x8c(%esi),%edx
80101571:	e8 28 fd ff ff       	call   8010129e <bfree>
    ip->addrs[NDIRECT] = 0;
80101576:	c7 86 8c 00 00 00 00 	movl   $0x0,0x8c(%esi)
8010157d:	00 00 00 
80101580:	83 c4 10             	add    $0x10,%esp
80101583:	eb 8b                	jmp    80101510 <itrunc+0x3d>

80101585 <idup>:
{
80101585:	55                   	push   %ebp
80101586:	89 e5                	mov    %esp,%ebp
80101588:	53                   	push   %ebx
80101589:	83 ec 10             	sub    $0x10,%esp
8010158c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&icache.lock);
8010158f:	68 40 1a 11 80       	push   $0x80111a40
80101594:	e8 e1 26 00 00       	call   80103c7a <acquire>
  ip->ref++;
80101599:	8b 43 08             	mov    0x8(%ebx),%eax
8010159c:	83 c0 01             	add    $0x1,%eax
8010159f:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
801015a2:	c7 04 24 40 1a 11 80 	movl   $0x80111a40,(%esp)
801015a9:	e8 31 27 00 00       	call   80103cdf <release>
}
801015ae:	89 d8                	mov    %ebx,%eax
801015b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801015b3:	c9                   	leave  
801015b4:	c3                   	ret    

801015b5 <ilock>:
{
801015b5:	55                   	push   %ebp
801015b6:	89 e5                	mov    %esp,%ebp
801015b8:	56                   	push   %esi
801015b9:	53                   	push   %ebx
801015ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || ip->ref < 1)
801015bd:	85 db                	test   %ebx,%ebx
801015bf:	74 22                	je     801015e3 <ilock+0x2e>
801015c1:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
801015c5:	7e 1c                	jle    801015e3 <ilock+0x2e>
  acquiresleep(&ip->lock);
801015c7:	83 ec 0c             	sub    $0xc,%esp
801015ca:	8d 43 0c             	lea    0xc(%ebx),%eax
801015cd:	50                   	push   %eax
801015ce:	e8 ba 24 00 00       	call   80103a8d <acquiresleep>
  if(ip->valid == 0){
801015d3:	83 c4 10             	add    $0x10,%esp
801015d6:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
801015da:	74 14                	je     801015f0 <ilock+0x3b>
}
801015dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
801015df:	5b                   	pop    %ebx
801015e0:	5e                   	pop    %esi
801015e1:	5d                   	pop    %ebp
801015e2:	c3                   	ret    
    panic("ilock");
801015e3:	83 ec 0c             	sub    $0xc,%esp
801015e6:	68 12 66 10 80       	push   $0x80106612
801015eb:	e8 58 ed ff ff       	call   80100348 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801015f0:	8b 43 04             	mov    0x4(%ebx),%eax
801015f3:	c1 e8 03             	shr    $0x3,%eax
801015f6:	03 05 34 1a 11 80    	add    0x80111a34,%eax
801015fc:	83 ec 08             	sub    $0x8,%esp
801015ff:	50                   	push   %eax
80101600:	ff 33                	pushl  (%ebx)
80101602:	e8 65 eb ff ff       	call   8010016c <bread>
80101607:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101609:	8b 43 04             	mov    0x4(%ebx),%eax
8010160c:	83 e0 07             	and    $0x7,%eax
8010160f:	c1 e0 06             	shl    $0x6,%eax
80101612:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
    ip->type = dip->type;
80101616:	0f b7 10             	movzwl (%eax),%edx
80101619:	66 89 53 50          	mov    %dx,0x50(%ebx)
    ip->major = dip->major;
8010161d:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101621:	66 89 53 52          	mov    %dx,0x52(%ebx)
    ip->minor = dip->minor;
80101625:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101629:	66 89 53 54          	mov    %dx,0x54(%ebx)
    ip->nlink = dip->nlink;
8010162d:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101631:	66 89 53 56          	mov    %dx,0x56(%ebx)
    ip->size = dip->size;
80101635:	8b 50 08             	mov    0x8(%eax),%edx
80101638:	89 53 58             	mov    %edx,0x58(%ebx)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
8010163b:	83 c0 0c             	add    $0xc,%eax
8010163e:	8d 53 5c             	lea    0x5c(%ebx),%edx
80101641:	83 c4 0c             	add    $0xc,%esp
80101644:	6a 34                	push   $0x34
80101646:	50                   	push   %eax
80101647:	52                   	push   %edx
80101648:	e8 54 27 00 00       	call   80103da1 <memmove>
    brelse(bp);
8010164d:	89 34 24             	mov    %esi,(%esp)
80101650:	e8 80 eb ff ff       	call   801001d5 <brelse>
    ip->valid = 1;
80101655:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
    if(ip->type == 0)
8010165c:	83 c4 10             	add    $0x10,%esp
8010165f:	66 83 7b 50 00       	cmpw   $0x0,0x50(%ebx)
80101664:	0f 85 72 ff ff ff    	jne    801015dc <ilock+0x27>
      panic("ilock: no type");
8010166a:	83 ec 0c             	sub    $0xc,%esp
8010166d:	68 18 66 10 80       	push   $0x80106618
80101672:	e8 d1 ec ff ff       	call   80100348 <panic>

80101677 <iunlock>:
{
80101677:	55                   	push   %ebp
80101678:	89 e5                	mov    %esp,%ebp
8010167a:	56                   	push   %esi
8010167b:	53                   	push   %ebx
8010167c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
8010167f:	85 db                	test   %ebx,%ebx
80101681:	74 2c                	je     801016af <iunlock+0x38>
80101683:	8d 73 0c             	lea    0xc(%ebx),%esi
80101686:	83 ec 0c             	sub    $0xc,%esp
80101689:	56                   	push   %esi
8010168a:	e8 88 24 00 00       	call   80103b17 <holdingsleep>
8010168f:	83 c4 10             	add    $0x10,%esp
80101692:	85 c0                	test   %eax,%eax
80101694:	74 19                	je     801016af <iunlock+0x38>
80101696:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
8010169a:	7e 13                	jle    801016af <iunlock+0x38>
  releasesleep(&ip->lock);
8010169c:	83 ec 0c             	sub    $0xc,%esp
8010169f:	56                   	push   %esi
801016a0:	e8 37 24 00 00       	call   80103adc <releasesleep>
}
801016a5:	83 c4 10             	add    $0x10,%esp
801016a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
801016ab:	5b                   	pop    %ebx
801016ac:	5e                   	pop    %esi
801016ad:	5d                   	pop    %ebp
801016ae:	c3                   	ret    
    panic("iunlock");
801016af:	83 ec 0c             	sub    $0xc,%esp
801016b2:	68 27 66 10 80       	push   $0x80106627
801016b7:	e8 8c ec ff ff       	call   80100348 <panic>

801016bc <iput>:
{
801016bc:	55                   	push   %ebp
801016bd:	89 e5                	mov    %esp,%ebp
801016bf:	57                   	push   %edi
801016c0:	56                   	push   %esi
801016c1:	53                   	push   %ebx
801016c2:	83 ec 18             	sub    $0x18,%esp
801016c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquiresleep(&ip->lock);
801016c8:	8d 73 0c             	lea    0xc(%ebx),%esi
801016cb:	56                   	push   %esi
801016cc:	e8 bc 23 00 00       	call   80103a8d <acquiresleep>
  if(ip->valid && ip->nlink == 0){
801016d1:	83 c4 10             	add    $0x10,%esp
801016d4:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
801016d8:	74 07                	je     801016e1 <iput+0x25>
801016da:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
801016df:	74 35                	je     80101716 <iput+0x5a>
  releasesleep(&ip->lock);
801016e1:	83 ec 0c             	sub    $0xc,%esp
801016e4:	56                   	push   %esi
801016e5:	e8 f2 23 00 00       	call   80103adc <releasesleep>
  acquire(&icache.lock);
801016ea:	c7 04 24 40 1a 11 80 	movl   $0x80111a40,(%esp)
801016f1:	e8 84 25 00 00       	call   80103c7a <acquire>
  ip->ref--;
801016f6:	8b 43 08             	mov    0x8(%ebx),%eax
801016f9:	83 e8 01             	sub    $0x1,%eax
801016fc:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
801016ff:	c7 04 24 40 1a 11 80 	movl   $0x80111a40,(%esp)
80101706:	e8 d4 25 00 00       	call   80103cdf <release>
}
8010170b:	83 c4 10             	add    $0x10,%esp
8010170e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101711:	5b                   	pop    %ebx
80101712:	5e                   	pop    %esi
80101713:	5f                   	pop    %edi
80101714:	5d                   	pop    %ebp
80101715:	c3                   	ret    
    acquire(&icache.lock);
80101716:	83 ec 0c             	sub    $0xc,%esp
80101719:	68 40 1a 11 80       	push   $0x80111a40
8010171e:	e8 57 25 00 00       	call   80103c7a <acquire>
    int r = ip->ref;
80101723:	8b 7b 08             	mov    0x8(%ebx),%edi
    release(&icache.lock);
80101726:	c7 04 24 40 1a 11 80 	movl   $0x80111a40,(%esp)
8010172d:	e8 ad 25 00 00       	call   80103cdf <release>
    if(r == 1){
80101732:	83 c4 10             	add    $0x10,%esp
80101735:	83 ff 01             	cmp    $0x1,%edi
80101738:	75 a7                	jne    801016e1 <iput+0x25>
      itrunc(ip);
8010173a:	89 d8                	mov    %ebx,%eax
8010173c:	e8 92 fd ff ff       	call   801014d3 <itrunc>
      ip->type = 0;
80101741:	66 c7 43 50 00 00    	movw   $0x0,0x50(%ebx)
      iupdate(ip);
80101747:	83 ec 0c             	sub    $0xc,%esp
8010174a:	53                   	push   %ebx
8010174b:	e8 04 fd ff ff       	call   80101454 <iupdate>
      ip->valid = 0;
80101750:	c7 43 4c 00 00 00 00 	movl   $0x0,0x4c(%ebx)
80101757:	83 c4 10             	add    $0x10,%esp
8010175a:	eb 85                	jmp    801016e1 <iput+0x25>

8010175c <iunlockput>:
{
8010175c:	55                   	push   %ebp
8010175d:	89 e5                	mov    %esp,%ebp
8010175f:	53                   	push   %ebx
80101760:	83 ec 10             	sub    $0x10,%esp
80101763:	8b 5d 08             	mov    0x8(%ebp),%ebx
  iunlock(ip);
80101766:	53                   	push   %ebx
80101767:	e8 0b ff ff ff       	call   80101677 <iunlock>
  iput(ip);
8010176c:	89 1c 24             	mov    %ebx,(%esp)
8010176f:	e8 48 ff ff ff       	call   801016bc <iput>
}
80101774:	83 c4 10             	add    $0x10,%esp
80101777:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010177a:	c9                   	leave  
8010177b:	c3                   	ret    

8010177c <stati>:
{
8010177c:	55                   	push   %ebp
8010177d:	89 e5                	mov    %esp,%ebp
8010177f:	8b 55 08             	mov    0x8(%ebp),%edx
80101782:	8b 45 0c             	mov    0xc(%ebp),%eax
  st->dev = ip->dev;
80101785:	8b 0a                	mov    (%edx),%ecx
80101787:	89 48 04             	mov    %ecx,0x4(%eax)
  st->ino = ip->inum;
8010178a:	8b 4a 04             	mov    0x4(%edx),%ecx
8010178d:	89 48 08             	mov    %ecx,0x8(%eax)
  st->type = ip->type;
80101790:	0f b7 4a 50          	movzwl 0x50(%edx),%ecx
80101794:	66 89 08             	mov    %cx,(%eax)
  st->nlink = ip->nlink;
80101797:	0f b7 4a 56          	movzwl 0x56(%edx),%ecx
8010179b:	66 89 48 0c          	mov    %cx,0xc(%eax)
  st->size = ip->size;
8010179f:	8b 52 58             	mov    0x58(%edx),%edx
801017a2:	89 50 10             	mov    %edx,0x10(%eax)
}
801017a5:	5d                   	pop    %ebp
801017a6:	c3                   	ret    

801017a7 <readi>:
{
801017a7:	55                   	push   %ebp
801017a8:	89 e5                	mov    %esp,%ebp
801017aa:	57                   	push   %edi
801017ab:	56                   	push   %esi
801017ac:	53                   	push   %ebx
801017ad:	83 ec 1c             	sub    $0x1c,%esp
801017b0:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(ip->type == T_DEV){
801017b3:	8b 45 08             	mov    0x8(%ebp),%eax
801017b6:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
801017bb:	74 2c                	je     801017e9 <readi+0x42>
  if(off > ip->size || off + n < off)
801017bd:	8b 45 08             	mov    0x8(%ebp),%eax
801017c0:	8b 40 58             	mov    0x58(%eax),%eax
801017c3:	39 f8                	cmp    %edi,%eax
801017c5:	0f 82 cb 00 00 00    	jb     80101896 <readi+0xef>
801017cb:	89 fa                	mov    %edi,%edx
801017cd:	03 55 14             	add    0x14(%ebp),%edx
801017d0:	0f 82 c7 00 00 00    	jb     8010189d <readi+0xf6>
  if(off + n > ip->size)
801017d6:	39 d0                	cmp    %edx,%eax
801017d8:	73 05                	jae    801017df <readi+0x38>
    n = ip->size - off;
801017da:	29 f8                	sub    %edi,%eax
801017dc:	89 45 14             	mov    %eax,0x14(%ebp)
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801017df:	be 00 00 00 00       	mov    $0x0,%esi
801017e4:	e9 8f 00 00 00       	jmp    80101878 <readi+0xd1>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
801017e9:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801017ed:	66 83 f8 09          	cmp    $0x9,%ax
801017f1:	0f 87 91 00 00 00    	ja     80101888 <readi+0xe1>
801017f7:	98                   	cwtl   
801017f8:	8b 04 c5 c0 19 11 80 	mov    -0x7feee640(,%eax,8),%eax
801017ff:	85 c0                	test   %eax,%eax
80101801:	0f 84 88 00 00 00    	je     8010188f <readi+0xe8>
    return devsw[ip->major].read(ip, dst, n);
80101807:	83 ec 04             	sub    $0x4,%esp
8010180a:	ff 75 14             	pushl  0x14(%ebp)
8010180d:	ff 75 0c             	pushl  0xc(%ebp)
80101810:	ff 75 08             	pushl  0x8(%ebp)
80101813:	ff d0                	call   *%eax
80101815:	83 c4 10             	add    $0x10,%esp
80101818:	eb 66                	jmp    80101880 <readi+0xd9>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
8010181a:	89 fa                	mov    %edi,%edx
8010181c:	c1 ea 09             	shr    $0x9,%edx
8010181f:	8b 45 08             	mov    0x8(%ebp),%eax
80101822:	e8 ee f8 ff ff       	call   80101115 <bmap>
80101827:	83 ec 08             	sub    $0x8,%esp
8010182a:	50                   	push   %eax
8010182b:	8b 45 08             	mov    0x8(%ebp),%eax
8010182e:	ff 30                	pushl  (%eax)
80101830:	e8 37 e9 ff ff       	call   8010016c <bread>
80101835:	89 c1                	mov    %eax,%ecx
    m = min(n - tot, BSIZE - off%BSIZE);
80101837:	89 f8                	mov    %edi,%eax
80101839:	25 ff 01 00 00       	and    $0x1ff,%eax
8010183e:	bb 00 02 00 00       	mov    $0x200,%ebx
80101843:	29 c3                	sub    %eax,%ebx
80101845:	8b 55 14             	mov    0x14(%ebp),%edx
80101848:	29 f2                	sub    %esi,%edx
8010184a:	83 c4 0c             	add    $0xc,%esp
8010184d:	39 d3                	cmp    %edx,%ebx
8010184f:	0f 47 da             	cmova  %edx,%ebx
    memmove(dst, bp->data + off%BSIZE, m);
80101852:	53                   	push   %ebx
80101853:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
80101856:	8d 44 01 5c          	lea    0x5c(%ecx,%eax,1),%eax
8010185a:	50                   	push   %eax
8010185b:	ff 75 0c             	pushl  0xc(%ebp)
8010185e:	e8 3e 25 00 00       	call   80103da1 <memmove>
    brelse(bp);
80101863:	83 c4 04             	add    $0x4,%esp
80101866:	ff 75 e4             	pushl  -0x1c(%ebp)
80101869:	e8 67 e9 ff ff       	call   801001d5 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010186e:	01 de                	add    %ebx,%esi
80101870:	01 df                	add    %ebx,%edi
80101872:	01 5d 0c             	add    %ebx,0xc(%ebp)
80101875:	83 c4 10             	add    $0x10,%esp
80101878:	39 75 14             	cmp    %esi,0x14(%ebp)
8010187b:	77 9d                	ja     8010181a <readi+0x73>
  return n;
8010187d:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101880:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101883:	5b                   	pop    %ebx
80101884:	5e                   	pop    %esi
80101885:	5f                   	pop    %edi
80101886:	5d                   	pop    %ebp
80101887:	c3                   	ret    
      return -1;
80101888:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010188d:	eb f1                	jmp    80101880 <readi+0xd9>
8010188f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101894:	eb ea                	jmp    80101880 <readi+0xd9>
    return -1;
80101896:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010189b:	eb e3                	jmp    80101880 <readi+0xd9>
8010189d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801018a2:	eb dc                	jmp    80101880 <readi+0xd9>

801018a4 <writei>:
{
801018a4:	55                   	push   %ebp
801018a5:	89 e5                	mov    %esp,%ebp
801018a7:	57                   	push   %edi
801018a8:	56                   	push   %esi
801018a9:	53                   	push   %ebx
801018aa:	83 ec 0c             	sub    $0xc,%esp
  if(ip->type == T_DEV){
801018ad:	8b 45 08             	mov    0x8(%ebp),%eax
801018b0:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
801018b5:	74 2f                	je     801018e6 <writei+0x42>
  if(off > ip->size || off + n < off)
801018b7:	8b 45 08             	mov    0x8(%ebp),%eax
801018ba:	8b 4d 10             	mov    0x10(%ebp),%ecx
801018bd:	39 48 58             	cmp    %ecx,0x58(%eax)
801018c0:	0f 82 f4 00 00 00    	jb     801019ba <writei+0x116>
801018c6:	89 c8                	mov    %ecx,%eax
801018c8:	03 45 14             	add    0x14(%ebp),%eax
801018cb:	0f 82 f0 00 00 00    	jb     801019c1 <writei+0x11d>
  if(off + n > MAXFILE*BSIZE)
801018d1:	3d 00 18 01 00       	cmp    $0x11800,%eax
801018d6:	0f 87 ec 00 00 00    	ja     801019c8 <writei+0x124>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801018dc:	be 00 00 00 00       	mov    $0x0,%esi
801018e1:	e9 94 00 00 00       	jmp    8010197a <writei+0xd6>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801018e6:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801018ea:	66 83 f8 09          	cmp    $0x9,%ax
801018ee:	0f 87 b8 00 00 00    	ja     801019ac <writei+0x108>
801018f4:	98                   	cwtl   
801018f5:	8b 04 c5 c4 19 11 80 	mov    -0x7feee63c(,%eax,8),%eax
801018fc:	85 c0                	test   %eax,%eax
801018fe:	0f 84 af 00 00 00    	je     801019b3 <writei+0x10f>
    return devsw[ip->major].write(ip, src, n);
80101904:	83 ec 04             	sub    $0x4,%esp
80101907:	ff 75 14             	pushl  0x14(%ebp)
8010190a:	ff 75 0c             	pushl  0xc(%ebp)
8010190d:	ff 75 08             	pushl  0x8(%ebp)
80101910:	ff d0                	call   *%eax
80101912:	83 c4 10             	add    $0x10,%esp
80101915:	eb 7c                	jmp    80101993 <writei+0xef>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101917:	8b 55 10             	mov    0x10(%ebp),%edx
8010191a:	c1 ea 09             	shr    $0x9,%edx
8010191d:	8b 45 08             	mov    0x8(%ebp),%eax
80101920:	e8 f0 f7 ff ff       	call   80101115 <bmap>
80101925:	83 ec 08             	sub    $0x8,%esp
80101928:	50                   	push   %eax
80101929:	8b 45 08             	mov    0x8(%ebp),%eax
8010192c:	ff 30                	pushl  (%eax)
8010192e:	e8 39 e8 ff ff       	call   8010016c <bread>
80101933:	89 c7                	mov    %eax,%edi
    m = min(n - tot, BSIZE - off%BSIZE);
80101935:	8b 45 10             	mov    0x10(%ebp),%eax
80101938:	25 ff 01 00 00       	and    $0x1ff,%eax
8010193d:	bb 00 02 00 00       	mov    $0x200,%ebx
80101942:	29 c3                	sub    %eax,%ebx
80101944:	8b 55 14             	mov    0x14(%ebp),%edx
80101947:	29 f2                	sub    %esi,%edx
80101949:	83 c4 0c             	add    $0xc,%esp
8010194c:	39 d3                	cmp    %edx,%ebx
8010194e:	0f 47 da             	cmova  %edx,%ebx
    memmove(bp->data + off%BSIZE, src, m);
80101951:	53                   	push   %ebx
80101952:	ff 75 0c             	pushl  0xc(%ebp)
80101955:	8d 44 07 5c          	lea    0x5c(%edi,%eax,1),%eax
80101959:	50                   	push   %eax
8010195a:	e8 42 24 00 00       	call   80103da1 <memmove>
    log_write(bp);
8010195f:	89 3c 24             	mov    %edi,(%esp)
80101962:	e8 a4 0f 00 00       	call   8010290b <log_write>
    brelse(bp);
80101967:	89 3c 24             	mov    %edi,(%esp)
8010196a:	e8 66 e8 ff ff       	call   801001d5 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010196f:	01 de                	add    %ebx,%esi
80101971:	01 5d 10             	add    %ebx,0x10(%ebp)
80101974:	01 5d 0c             	add    %ebx,0xc(%ebp)
80101977:	83 c4 10             	add    $0x10,%esp
8010197a:	3b 75 14             	cmp    0x14(%ebp),%esi
8010197d:	72 98                	jb     80101917 <writei+0x73>
  if(n > 0 && off > ip->size){
8010197f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80101983:	74 0b                	je     80101990 <writei+0xec>
80101985:	8b 45 08             	mov    0x8(%ebp),%eax
80101988:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010198b:	39 48 58             	cmp    %ecx,0x58(%eax)
8010198e:	72 0b                	jb     8010199b <writei+0xf7>
  return n;
80101990:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101993:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101996:	5b                   	pop    %ebx
80101997:	5e                   	pop    %esi
80101998:	5f                   	pop    %edi
80101999:	5d                   	pop    %ebp
8010199a:	c3                   	ret    
    ip->size = off;
8010199b:	89 48 58             	mov    %ecx,0x58(%eax)
    iupdate(ip);
8010199e:	83 ec 0c             	sub    $0xc,%esp
801019a1:	50                   	push   %eax
801019a2:	e8 ad fa ff ff       	call   80101454 <iupdate>
801019a7:	83 c4 10             	add    $0x10,%esp
801019aa:	eb e4                	jmp    80101990 <writei+0xec>
      return -1;
801019ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801019b1:	eb e0                	jmp    80101993 <writei+0xef>
801019b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801019b8:	eb d9                	jmp    80101993 <writei+0xef>
    return -1;
801019ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801019bf:	eb d2                	jmp    80101993 <writei+0xef>
801019c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801019c6:	eb cb                	jmp    80101993 <writei+0xef>
    return -1;
801019c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801019cd:	eb c4                	jmp    80101993 <writei+0xef>

801019cf <namecmp>:
{
801019cf:	55                   	push   %ebp
801019d0:	89 e5                	mov    %esp,%ebp
801019d2:	83 ec 0c             	sub    $0xc,%esp
  return strncmp(s, t, DIRSIZ);
801019d5:	6a 0e                	push   $0xe
801019d7:	ff 75 0c             	pushl  0xc(%ebp)
801019da:	ff 75 08             	pushl  0x8(%ebp)
801019dd:	e8 26 24 00 00       	call   80103e08 <strncmp>
}
801019e2:	c9                   	leave  
801019e3:	c3                   	ret    

801019e4 <dirlookup>:
{
801019e4:	55                   	push   %ebp
801019e5:	89 e5                	mov    %esp,%ebp
801019e7:	57                   	push   %edi
801019e8:	56                   	push   %esi
801019e9:	53                   	push   %ebx
801019ea:	83 ec 1c             	sub    $0x1c,%esp
801019ed:	8b 75 08             	mov    0x8(%ebp),%esi
801019f0:	8b 7d 0c             	mov    0xc(%ebp),%edi
  if(dp->type != T_DIR)
801019f3:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
801019f8:	75 07                	jne    80101a01 <dirlookup+0x1d>
  for(off = 0; off < dp->size; off += sizeof(de)){
801019fa:	bb 00 00 00 00       	mov    $0x0,%ebx
801019ff:	eb 1d                	jmp    80101a1e <dirlookup+0x3a>
    panic("dirlookup not DIR");
80101a01:	83 ec 0c             	sub    $0xc,%esp
80101a04:	68 2f 66 10 80       	push   $0x8010662f
80101a09:	e8 3a e9 ff ff       	call   80100348 <panic>
      panic("dirlookup read");
80101a0e:	83 ec 0c             	sub    $0xc,%esp
80101a11:	68 41 66 10 80       	push   $0x80106641
80101a16:	e8 2d e9 ff ff       	call   80100348 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101a1b:	83 c3 10             	add    $0x10,%ebx
80101a1e:	39 5e 58             	cmp    %ebx,0x58(%esi)
80101a21:	76 48                	jbe    80101a6b <dirlookup+0x87>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101a23:	6a 10                	push   $0x10
80101a25:	53                   	push   %ebx
80101a26:	8d 45 d8             	lea    -0x28(%ebp),%eax
80101a29:	50                   	push   %eax
80101a2a:	56                   	push   %esi
80101a2b:	e8 77 fd ff ff       	call   801017a7 <readi>
80101a30:	83 c4 10             	add    $0x10,%esp
80101a33:	83 f8 10             	cmp    $0x10,%eax
80101a36:	75 d6                	jne    80101a0e <dirlookup+0x2a>
    if(de.inum == 0)
80101a38:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101a3d:	74 dc                	je     80101a1b <dirlookup+0x37>
    if(namecmp(name, de.name) == 0){
80101a3f:	83 ec 08             	sub    $0x8,%esp
80101a42:	8d 45 da             	lea    -0x26(%ebp),%eax
80101a45:	50                   	push   %eax
80101a46:	57                   	push   %edi
80101a47:	e8 83 ff ff ff       	call   801019cf <namecmp>
80101a4c:	83 c4 10             	add    $0x10,%esp
80101a4f:	85 c0                	test   %eax,%eax
80101a51:	75 c8                	jne    80101a1b <dirlookup+0x37>
      if(poff)
80101a53:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80101a57:	74 05                	je     80101a5e <dirlookup+0x7a>
        *poff = off;
80101a59:	8b 45 10             	mov    0x10(%ebp),%eax
80101a5c:	89 18                	mov    %ebx,(%eax)
      inum = de.inum;
80101a5e:	0f b7 55 d8          	movzwl -0x28(%ebp),%edx
      return iget(dp->dev, inum);
80101a62:	8b 06                	mov    (%esi),%eax
80101a64:	e8 52 f7 ff ff       	call   801011bb <iget>
80101a69:	eb 05                	jmp    80101a70 <dirlookup+0x8c>
  return 0;
80101a6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101a70:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101a73:	5b                   	pop    %ebx
80101a74:	5e                   	pop    %esi
80101a75:	5f                   	pop    %edi
80101a76:	5d                   	pop    %ebp
80101a77:	c3                   	ret    

80101a78 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80101a78:	55                   	push   %ebp
80101a79:	89 e5                	mov    %esp,%ebp
80101a7b:	57                   	push   %edi
80101a7c:	56                   	push   %esi
80101a7d:	53                   	push   %ebx
80101a7e:	83 ec 1c             	sub    $0x1c,%esp
80101a81:	89 c6                	mov    %eax,%esi
80101a83:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101a86:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  struct inode *ip, *next;

  if(*path == '/')
80101a89:	80 38 2f             	cmpb   $0x2f,(%eax)
80101a8c:	74 17                	je     80101aa5 <namex+0x2d>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
80101a8e:	e8 ae 17 00 00       	call   80103241 <myproc>
80101a93:	83 ec 0c             	sub    $0xc,%esp
80101a96:	ff 70 6c             	pushl  0x6c(%eax)
80101a99:	e8 e7 fa ff ff       	call   80101585 <idup>
80101a9e:	89 c3                	mov    %eax,%ebx
80101aa0:	83 c4 10             	add    $0x10,%esp
80101aa3:	eb 53                	jmp    80101af8 <namex+0x80>
    ip = iget(ROOTDEV, ROOTINO);
80101aa5:	ba 01 00 00 00       	mov    $0x1,%edx
80101aaa:	b8 01 00 00 00       	mov    $0x1,%eax
80101aaf:	e8 07 f7 ff ff       	call   801011bb <iget>
80101ab4:	89 c3                	mov    %eax,%ebx
80101ab6:	eb 40                	jmp    80101af8 <namex+0x80>

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
      iunlockput(ip);
80101ab8:	83 ec 0c             	sub    $0xc,%esp
80101abb:	53                   	push   %ebx
80101abc:	e8 9b fc ff ff       	call   8010175c <iunlockput>
      return 0;
80101ac1:	83 c4 10             	add    $0x10,%esp
80101ac4:	bb 00 00 00 00       	mov    $0x0,%ebx
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
80101ac9:	89 d8                	mov    %ebx,%eax
80101acb:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101ace:	5b                   	pop    %ebx
80101acf:	5e                   	pop    %esi
80101ad0:	5f                   	pop    %edi
80101ad1:	5d                   	pop    %ebp
80101ad2:	c3                   	ret    
    if((next = dirlookup(ip, name, 0)) == 0){
80101ad3:	83 ec 04             	sub    $0x4,%esp
80101ad6:	6a 00                	push   $0x0
80101ad8:	ff 75 e4             	pushl  -0x1c(%ebp)
80101adb:	53                   	push   %ebx
80101adc:	e8 03 ff ff ff       	call   801019e4 <dirlookup>
80101ae1:	89 c7                	mov    %eax,%edi
80101ae3:	83 c4 10             	add    $0x10,%esp
80101ae6:	85 c0                	test   %eax,%eax
80101ae8:	74 4a                	je     80101b34 <namex+0xbc>
    iunlockput(ip);
80101aea:	83 ec 0c             	sub    $0xc,%esp
80101aed:	53                   	push   %ebx
80101aee:	e8 69 fc ff ff       	call   8010175c <iunlockput>
    ip = next;
80101af3:	83 c4 10             	add    $0x10,%esp
80101af6:	89 fb                	mov    %edi,%ebx
  while((path = skipelem(path, name)) != 0){
80101af8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101afb:	89 f0                	mov    %esi,%eax
80101afd:	e8 77 f4 ff ff       	call   80100f79 <skipelem>
80101b02:	89 c6                	mov    %eax,%esi
80101b04:	85 c0                	test   %eax,%eax
80101b06:	74 3c                	je     80101b44 <namex+0xcc>
    ilock(ip);
80101b08:	83 ec 0c             	sub    $0xc,%esp
80101b0b:	53                   	push   %ebx
80101b0c:	e8 a4 fa ff ff       	call   801015b5 <ilock>
    if(ip->type != T_DIR){
80101b11:	83 c4 10             	add    $0x10,%esp
80101b14:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80101b19:	75 9d                	jne    80101ab8 <namex+0x40>
    if(nameiparent && *path == '\0'){
80101b1b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101b1f:	74 b2                	je     80101ad3 <namex+0x5b>
80101b21:	80 3e 00             	cmpb   $0x0,(%esi)
80101b24:	75 ad                	jne    80101ad3 <namex+0x5b>
      iunlock(ip);
80101b26:	83 ec 0c             	sub    $0xc,%esp
80101b29:	53                   	push   %ebx
80101b2a:	e8 48 fb ff ff       	call   80101677 <iunlock>
      return ip;
80101b2f:	83 c4 10             	add    $0x10,%esp
80101b32:	eb 95                	jmp    80101ac9 <namex+0x51>
      iunlockput(ip);
80101b34:	83 ec 0c             	sub    $0xc,%esp
80101b37:	53                   	push   %ebx
80101b38:	e8 1f fc ff ff       	call   8010175c <iunlockput>
      return 0;
80101b3d:	83 c4 10             	add    $0x10,%esp
80101b40:	89 fb                	mov    %edi,%ebx
80101b42:	eb 85                	jmp    80101ac9 <namex+0x51>
  if(nameiparent){
80101b44:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101b48:	0f 84 7b ff ff ff    	je     80101ac9 <namex+0x51>
    iput(ip);
80101b4e:	83 ec 0c             	sub    $0xc,%esp
80101b51:	53                   	push   %ebx
80101b52:	e8 65 fb ff ff       	call   801016bc <iput>
    return 0;
80101b57:	83 c4 10             	add    $0x10,%esp
80101b5a:	bb 00 00 00 00       	mov    $0x0,%ebx
80101b5f:	e9 65 ff ff ff       	jmp    80101ac9 <namex+0x51>

80101b64 <dirlink>:
{
80101b64:	55                   	push   %ebp
80101b65:	89 e5                	mov    %esp,%ebp
80101b67:	57                   	push   %edi
80101b68:	56                   	push   %esi
80101b69:	53                   	push   %ebx
80101b6a:	83 ec 20             	sub    $0x20,%esp
80101b6d:	8b 5d 08             	mov    0x8(%ebp),%ebx
80101b70:	8b 7d 0c             	mov    0xc(%ebp),%edi
  if((ip = dirlookup(dp, name, 0)) != 0){
80101b73:	6a 00                	push   $0x0
80101b75:	57                   	push   %edi
80101b76:	53                   	push   %ebx
80101b77:	e8 68 fe ff ff       	call   801019e4 <dirlookup>
80101b7c:	83 c4 10             	add    $0x10,%esp
80101b7f:	85 c0                	test   %eax,%eax
80101b81:	75 2d                	jne    80101bb0 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101b83:	b8 00 00 00 00       	mov    $0x0,%eax
80101b88:	89 c6                	mov    %eax,%esi
80101b8a:	39 43 58             	cmp    %eax,0x58(%ebx)
80101b8d:	76 41                	jbe    80101bd0 <dirlink+0x6c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101b8f:	6a 10                	push   $0x10
80101b91:	50                   	push   %eax
80101b92:	8d 45 d8             	lea    -0x28(%ebp),%eax
80101b95:	50                   	push   %eax
80101b96:	53                   	push   %ebx
80101b97:	e8 0b fc ff ff       	call   801017a7 <readi>
80101b9c:	83 c4 10             	add    $0x10,%esp
80101b9f:	83 f8 10             	cmp    $0x10,%eax
80101ba2:	75 1f                	jne    80101bc3 <dirlink+0x5f>
    if(de.inum == 0)
80101ba4:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101ba9:	74 25                	je     80101bd0 <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101bab:	8d 46 10             	lea    0x10(%esi),%eax
80101bae:	eb d8                	jmp    80101b88 <dirlink+0x24>
    iput(ip);
80101bb0:	83 ec 0c             	sub    $0xc,%esp
80101bb3:	50                   	push   %eax
80101bb4:	e8 03 fb ff ff       	call   801016bc <iput>
    return -1;
80101bb9:	83 c4 10             	add    $0x10,%esp
80101bbc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101bc1:	eb 3d                	jmp    80101c00 <dirlink+0x9c>
      panic("dirlink read");
80101bc3:	83 ec 0c             	sub    $0xc,%esp
80101bc6:	68 50 66 10 80       	push   $0x80106650
80101bcb:	e8 78 e7 ff ff       	call   80100348 <panic>
  strncpy(de.name, name, DIRSIZ);
80101bd0:	83 ec 04             	sub    $0x4,%esp
80101bd3:	6a 0e                	push   $0xe
80101bd5:	57                   	push   %edi
80101bd6:	8d 7d d8             	lea    -0x28(%ebp),%edi
80101bd9:	8d 45 da             	lea    -0x26(%ebp),%eax
80101bdc:	50                   	push   %eax
80101bdd:	e8 63 22 00 00       	call   80103e45 <strncpy>
  de.inum = inum;
80101be2:	8b 45 10             	mov    0x10(%ebp),%eax
80101be5:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101be9:	6a 10                	push   $0x10
80101beb:	56                   	push   %esi
80101bec:	57                   	push   %edi
80101bed:	53                   	push   %ebx
80101bee:	e8 b1 fc ff ff       	call   801018a4 <writei>
80101bf3:	83 c4 20             	add    $0x20,%esp
80101bf6:	83 f8 10             	cmp    $0x10,%eax
80101bf9:	75 0d                	jne    80101c08 <dirlink+0xa4>
  return 0;
80101bfb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101c00:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101c03:	5b                   	pop    %ebx
80101c04:	5e                   	pop    %esi
80101c05:	5f                   	pop    %edi
80101c06:	5d                   	pop    %ebp
80101c07:	c3                   	ret    
    panic("dirlink");
80101c08:	83 ec 0c             	sub    $0xc,%esp
80101c0b:	68 98 6c 10 80       	push   $0x80106c98
80101c10:	e8 33 e7 ff ff       	call   80100348 <panic>

80101c15 <namei>:

struct inode*
namei(char *path)
{
80101c15:	55                   	push   %ebp
80101c16:	89 e5                	mov    %esp,%ebp
80101c18:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80101c1b:	8d 4d ea             	lea    -0x16(%ebp),%ecx
80101c1e:	ba 00 00 00 00       	mov    $0x0,%edx
80101c23:	8b 45 08             	mov    0x8(%ebp),%eax
80101c26:	e8 4d fe ff ff       	call   80101a78 <namex>
}
80101c2b:	c9                   	leave  
80101c2c:	c3                   	ret    

80101c2d <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80101c2d:	55                   	push   %ebp
80101c2e:	89 e5                	mov    %esp,%ebp
80101c30:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80101c33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80101c36:	ba 01 00 00 00       	mov    $0x1,%edx
80101c3b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c3e:	e8 35 fe ff ff       	call   80101a78 <namex>
}
80101c43:	c9                   	leave  
80101c44:	c3                   	ret    

80101c45 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80101c45:	55                   	push   %ebp
80101c46:	89 e5                	mov    %esp,%ebp
80101c48:	89 c1                	mov    %eax,%ecx
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101c4a:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101c4f:	ec                   	in     (%dx),%al
80101c50:	89 c2                	mov    %eax,%edx
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80101c52:	83 e0 c0             	and    $0xffffffc0,%eax
80101c55:	3c 40                	cmp    $0x40,%al
80101c57:	75 f1                	jne    80101c4a <idewait+0x5>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80101c59:	85 c9                	test   %ecx,%ecx
80101c5b:	74 0c                	je     80101c69 <idewait+0x24>
80101c5d:	f6 c2 21             	test   $0x21,%dl
80101c60:	75 0e                	jne    80101c70 <idewait+0x2b>
    return -1;
  return 0;
80101c62:	b8 00 00 00 00       	mov    $0x0,%eax
80101c67:	eb 05                	jmp    80101c6e <idewait+0x29>
80101c69:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101c6e:	5d                   	pop    %ebp
80101c6f:	c3                   	ret    
    return -1;
80101c70:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101c75:	eb f7                	jmp    80101c6e <idewait+0x29>

80101c77 <idestart>:
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80101c77:	55                   	push   %ebp
80101c78:	89 e5                	mov    %esp,%ebp
80101c7a:	56                   	push   %esi
80101c7b:	53                   	push   %ebx
  if(b == 0)
80101c7c:	85 c0                	test   %eax,%eax
80101c7e:	74 7d                	je     80101cfd <idestart+0x86>
80101c80:	89 c6                	mov    %eax,%esi
    panic("idestart");
  if(b->blockno >= FSSIZE)
80101c82:	8b 58 08             	mov    0x8(%eax),%ebx
80101c85:	81 fb cf 07 00 00    	cmp    $0x7cf,%ebx
80101c8b:	77 7d                	ja     80101d0a <idestart+0x93>
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;

  if (sector_per_block > 7) panic("idestart");

  idewait(0);
80101c8d:	b8 00 00 00 00       	mov    $0x0,%eax
80101c92:	e8 ae ff ff ff       	call   80101c45 <idewait>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101c97:	b8 00 00 00 00       	mov    $0x0,%eax
80101c9c:	ba f6 03 00 00       	mov    $0x3f6,%edx
80101ca1:	ee                   	out    %al,(%dx)
80101ca2:	b8 01 00 00 00       	mov    $0x1,%eax
80101ca7:	ba f2 01 00 00       	mov    $0x1f2,%edx
80101cac:	ee                   	out    %al,(%dx)
80101cad:	ba f3 01 00 00       	mov    $0x1f3,%edx
80101cb2:	89 d8                	mov    %ebx,%eax
80101cb4:	ee                   	out    %al,(%dx)
  outb(0x3f6, 0);  // generate interrupt
  outb(0x1f2, sector_per_block);  // number of sectors
  outb(0x1f3, sector & 0xff);
  outb(0x1f4, (sector >> 8) & 0xff);
80101cb5:	89 d8                	mov    %ebx,%eax
80101cb7:	c1 f8 08             	sar    $0x8,%eax
80101cba:	ba f4 01 00 00       	mov    $0x1f4,%edx
80101cbf:	ee                   	out    %al,(%dx)
  outb(0x1f5, (sector >> 16) & 0xff);
80101cc0:	89 d8                	mov    %ebx,%eax
80101cc2:	c1 f8 10             	sar    $0x10,%eax
80101cc5:	ba f5 01 00 00       	mov    $0x1f5,%edx
80101cca:	ee                   	out    %al,(%dx)
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80101ccb:	0f b6 46 04          	movzbl 0x4(%esi),%eax
80101ccf:	c1 e0 04             	shl    $0x4,%eax
80101cd2:	83 e0 10             	and    $0x10,%eax
80101cd5:	c1 fb 18             	sar    $0x18,%ebx
80101cd8:	83 e3 0f             	and    $0xf,%ebx
80101cdb:	09 d8                	or     %ebx,%eax
80101cdd:	83 c8 e0             	or     $0xffffffe0,%eax
80101ce0:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101ce5:	ee                   	out    %al,(%dx)
  if(b->flags & B_DIRTY){
80101ce6:	f6 06 04             	testb  $0x4,(%esi)
80101ce9:	75 2c                	jne    80101d17 <idestart+0xa0>
80101ceb:	b8 20 00 00 00       	mov    $0x20,%eax
80101cf0:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101cf5:	ee                   	out    %al,(%dx)
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, read_cmd);
  }
}
80101cf6:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101cf9:	5b                   	pop    %ebx
80101cfa:	5e                   	pop    %esi
80101cfb:	5d                   	pop    %ebp
80101cfc:	c3                   	ret    
    panic("idestart");
80101cfd:	83 ec 0c             	sub    $0xc,%esp
80101d00:	68 b3 66 10 80       	push   $0x801066b3
80101d05:	e8 3e e6 ff ff       	call   80100348 <panic>
    panic("incorrect blockno");
80101d0a:	83 ec 0c             	sub    $0xc,%esp
80101d0d:	68 bc 66 10 80       	push   $0x801066bc
80101d12:	e8 31 e6 ff ff       	call   80100348 <panic>
80101d17:	b8 30 00 00 00       	mov    $0x30,%eax
80101d1c:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101d21:	ee                   	out    %al,(%dx)
    outsl(0x1f0, b->data, BSIZE/4);
80101d22:	83 c6 5c             	add    $0x5c,%esi
  asm volatile("cld; rep outsl" :
80101d25:	b9 80 00 00 00       	mov    $0x80,%ecx
80101d2a:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101d2f:	fc                   	cld    
80101d30:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80101d32:	eb c2                	jmp    80101cf6 <idestart+0x7f>

80101d34 <ideinit>:
{
80101d34:	55                   	push   %ebp
80101d35:	89 e5                	mov    %esp,%ebp
80101d37:	83 ec 10             	sub    $0x10,%esp
  initlock(&idelock, "ide");
80101d3a:	68 ce 66 10 80       	push   $0x801066ce
80101d3f:	68 80 95 10 80       	push   $0x80109580
80101d44:	e8 f5 1d 00 00       	call   80103b3e <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
80101d49:	83 c4 08             	add    $0x8,%esp
80101d4c:	a1 60 3d 11 80       	mov    0x80113d60,%eax
80101d51:	83 e8 01             	sub    $0x1,%eax
80101d54:	50                   	push   %eax
80101d55:	6a 0e                	push   $0xe
80101d57:	e8 56 02 00 00       	call   80101fb2 <ioapicenable>
  idewait(0);
80101d5c:	b8 00 00 00 00       	mov    $0x0,%eax
80101d61:	e8 df fe ff ff       	call   80101c45 <idewait>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101d66:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
80101d6b:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101d70:	ee                   	out    %al,(%dx)
  for(i=0; i<1000; i++){
80101d71:	83 c4 10             	add    $0x10,%esp
80101d74:	b9 00 00 00 00       	mov    $0x0,%ecx
80101d79:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
80101d7f:	7f 19                	jg     80101d9a <ideinit+0x66>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101d81:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101d86:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
80101d87:	84 c0                	test   %al,%al
80101d89:	75 05                	jne    80101d90 <ideinit+0x5c>
  for(i=0; i<1000; i++){
80101d8b:	83 c1 01             	add    $0x1,%ecx
80101d8e:	eb e9                	jmp    80101d79 <ideinit+0x45>
      havedisk1 = 1;
80101d90:	c7 05 60 95 10 80 01 	movl   $0x1,0x80109560
80101d97:	00 00 00 
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101d9a:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
80101d9f:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101da4:	ee                   	out    %al,(%dx)
}
80101da5:	c9                   	leave  
80101da6:	c3                   	ret    

80101da7 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80101da7:	55                   	push   %ebp
80101da8:	89 e5                	mov    %esp,%ebp
80101daa:	57                   	push   %edi
80101dab:	53                   	push   %ebx
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80101dac:	83 ec 0c             	sub    $0xc,%esp
80101daf:	68 80 95 10 80       	push   $0x80109580
80101db4:	e8 c1 1e 00 00       	call   80103c7a <acquire>

  if((b = idequeue) == 0){
80101db9:	8b 1d 64 95 10 80    	mov    0x80109564,%ebx
80101dbf:	83 c4 10             	add    $0x10,%esp
80101dc2:	85 db                	test   %ebx,%ebx
80101dc4:	74 48                	je     80101e0e <ideintr+0x67>
    release(&idelock);
    return;
  }
  idequeue = b->qnext;
80101dc6:	8b 43 58             	mov    0x58(%ebx),%eax
80101dc9:	a3 64 95 10 80       	mov    %eax,0x80109564

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80101dce:	f6 03 04             	testb  $0x4,(%ebx)
80101dd1:	74 4d                	je     80101e20 <ideintr+0x79>
    insl(0x1f0, b->data, BSIZE/4);

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80101dd3:	8b 03                	mov    (%ebx),%eax
80101dd5:	83 c8 02             	or     $0x2,%eax
  b->flags &= ~B_DIRTY;
80101dd8:	83 e0 fb             	and    $0xfffffffb,%eax
80101ddb:	89 03                	mov    %eax,(%ebx)
  wakeup(b);
80101ddd:	83 ec 0c             	sub    $0xc,%esp
80101de0:	53                   	push   %ebx
80101de1:	e8 8d 1a 00 00       	call   80103873 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80101de6:	a1 64 95 10 80       	mov    0x80109564,%eax
80101deb:	83 c4 10             	add    $0x10,%esp
80101dee:	85 c0                	test   %eax,%eax
80101df0:	74 05                	je     80101df7 <ideintr+0x50>
    idestart(idequeue);
80101df2:	e8 80 fe ff ff       	call   80101c77 <idestart>

  release(&idelock);
80101df7:	83 ec 0c             	sub    $0xc,%esp
80101dfa:	68 80 95 10 80       	push   $0x80109580
80101dff:	e8 db 1e 00 00       	call   80103cdf <release>
80101e04:	83 c4 10             	add    $0x10,%esp
}
80101e07:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101e0a:	5b                   	pop    %ebx
80101e0b:	5f                   	pop    %edi
80101e0c:	5d                   	pop    %ebp
80101e0d:	c3                   	ret    
    release(&idelock);
80101e0e:	83 ec 0c             	sub    $0xc,%esp
80101e11:	68 80 95 10 80       	push   $0x80109580
80101e16:	e8 c4 1e 00 00       	call   80103cdf <release>
    return;
80101e1b:	83 c4 10             	add    $0x10,%esp
80101e1e:	eb e7                	jmp    80101e07 <ideintr+0x60>
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80101e20:	b8 01 00 00 00       	mov    $0x1,%eax
80101e25:	e8 1b fe ff ff       	call   80101c45 <idewait>
80101e2a:	85 c0                	test   %eax,%eax
80101e2c:	78 a5                	js     80101dd3 <ideintr+0x2c>
    insl(0x1f0, b->data, BSIZE/4);
80101e2e:	8d 7b 5c             	lea    0x5c(%ebx),%edi
  asm volatile("cld; rep insl" :
80101e31:	b9 80 00 00 00       	mov    $0x80,%ecx
80101e36:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101e3b:	fc                   	cld    
80101e3c:	f3 6d                	rep insl (%dx),%es:(%edi)
80101e3e:	eb 93                	jmp    80101dd3 <ideintr+0x2c>

80101e40 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80101e40:	55                   	push   %ebp
80101e41:	89 e5                	mov    %esp,%ebp
80101e43:	53                   	push   %ebx
80101e44:	83 ec 10             	sub    $0x10,%esp
80101e47:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80101e4a:	8d 43 0c             	lea    0xc(%ebx),%eax
80101e4d:	50                   	push   %eax
80101e4e:	e8 c4 1c 00 00       	call   80103b17 <holdingsleep>
80101e53:	83 c4 10             	add    $0x10,%esp
80101e56:	85 c0                	test   %eax,%eax
80101e58:	74 37                	je     80101e91 <iderw+0x51>
    panic("iderw: buf not locked");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80101e5a:	8b 03                	mov    (%ebx),%eax
80101e5c:	83 e0 06             	and    $0x6,%eax
80101e5f:	83 f8 02             	cmp    $0x2,%eax
80101e62:	74 3a                	je     80101e9e <iderw+0x5e>
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
80101e64:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
80101e68:	74 09                	je     80101e73 <iderw+0x33>
80101e6a:	83 3d 60 95 10 80 00 	cmpl   $0x0,0x80109560
80101e71:	74 38                	je     80101eab <iderw+0x6b>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);  //DOC:acquire-lock
80101e73:	83 ec 0c             	sub    $0xc,%esp
80101e76:	68 80 95 10 80       	push   $0x80109580
80101e7b:	e8 fa 1d 00 00       	call   80103c7a <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80101e80:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101e87:	83 c4 10             	add    $0x10,%esp
80101e8a:	ba 64 95 10 80       	mov    $0x80109564,%edx
80101e8f:	eb 2a                	jmp    80101ebb <iderw+0x7b>
    panic("iderw: buf not locked");
80101e91:	83 ec 0c             	sub    $0xc,%esp
80101e94:	68 d2 66 10 80       	push   $0x801066d2
80101e99:	e8 aa e4 ff ff       	call   80100348 <panic>
    panic("iderw: nothing to do");
80101e9e:	83 ec 0c             	sub    $0xc,%esp
80101ea1:	68 e8 66 10 80       	push   $0x801066e8
80101ea6:	e8 9d e4 ff ff       	call   80100348 <panic>
    panic("iderw: ide disk 1 not present");
80101eab:	83 ec 0c             	sub    $0xc,%esp
80101eae:	68 fd 66 10 80       	push   $0x801066fd
80101eb3:	e8 90 e4 ff ff       	call   80100348 <panic>
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101eb8:	8d 50 58             	lea    0x58(%eax),%edx
80101ebb:	8b 02                	mov    (%edx),%eax
80101ebd:	85 c0                	test   %eax,%eax
80101ebf:	75 f7                	jne    80101eb8 <iderw+0x78>
    ;
  *pp = b;
80101ec1:	89 1a                	mov    %ebx,(%edx)

  // Start disk if necessary.
  if(idequeue == b)
80101ec3:	39 1d 64 95 10 80    	cmp    %ebx,0x80109564
80101ec9:	75 1a                	jne    80101ee5 <iderw+0xa5>
    idestart(b);
80101ecb:	89 d8                	mov    %ebx,%eax
80101ecd:	e8 a5 fd ff ff       	call   80101c77 <idestart>
80101ed2:	eb 11                	jmp    80101ee5 <iderw+0xa5>

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
    sleep(b, &idelock);
80101ed4:	83 ec 08             	sub    $0x8,%esp
80101ed7:	68 80 95 10 80       	push   $0x80109580
80101edc:	53                   	push   %ebx
80101edd:	e8 2d 18 00 00       	call   8010370f <sleep>
80101ee2:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80101ee5:	8b 03                	mov    (%ebx),%eax
80101ee7:	83 e0 06             	and    $0x6,%eax
80101eea:	83 f8 02             	cmp    $0x2,%eax
80101eed:	75 e5                	jne    80101ed4 <iderw+0x94>
  }


  release(&idelock);
80101eef:	83 ec 0c             	sub    $0xc,%esp
80101ef2:	68 80 95 10 80       	push   $0x80109580
80101ef7:	e8 e3 1d 00 00       	call   80103cdf <release>
}
80101efc:	83 c4 10             	add    $0x10,%esp
80101eff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101f02:	c9                   	leave  
80101f03:	c3                   	ret    

80101f04 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80101f04:	55                   	push   %ebp
80101f05:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80101f07:	8b 15 94 36 11 80    	mov    0x80113694,%edx
80101f0d:	89 02                	mov    %eax,(%edx)
  return ioapic->data;
80101f0f:	a1 94 36 11 80       	mov    0x80113694,%eax
80101f14:	8b 40 10             	mov    0x10(%eax),%eax
}
80101f17:	5d                   	pop    %ebp
80101f18:	c3                   	ret    

80101f19 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80101f19:	55                   	push   %ebp
80101f1a:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80101f1c:	8b 0d 94 36 11 80    	mov    0x80113694,%ecx
80101f22:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
80101f24:	a1 94 36 11 80       	mov    0x80113694,%eax
80101f29:	89 50 10             	mov    %edx,0x10(%eax)
}
80101f2c:	5d                   	pop    %ebp
80101f2d:	c3                   	ret    

80101f2e <ioapicinit>:

void
ioapicinit(void)
{
80101f2e:	55                   	push   %ebp
80101f2f:	89 e5                	mov    %esp,%ebp
80101f31:	57                   	push   %edi
80101f32:	56                   	push   %esi
80101f33:	53                   	push   %ebx
80101f34:	83 ec 0c             	sub    $0xc,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80101f37:	c7 05 94 36 11 80 00 	movl   $0xfec00000,0x80113694
80101f3e:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80101f41:	b8 01 00 00 00       	mov    $0x1,%eax
80101f46:	e8 b9 ff ff ff       	call   80101f04 <ioapicread>
80101f4b:	c1 e8 10             	shr    $0x10,%eax
80101f4e:	0f b6 f8             	movzbl %al,%edi
  id = ioapicread(REG_ID) >> 24;
80101f51:	b8 00 00 00 00       	mov    $0x0,%eax
80101f56:	e8 a9 ff ff ff       	call   80101f04 <ioapicread>
80101f5b:	c1 e8 18             	shr    $0x18,%eax
  if(id != ioapicid)
80101f5e:	0f b6 15 c0 37 11 80 	movzbl 0x801137c0,%edx
80101f65:	39 c2                	cmp    %eax,%edx
80101f67:	75 07                	jne    80101f70 <ioapicinit+0x42>
{
80101f69:	bb 00 00 00 00       	mov    $0x0,%ebx
80101f6e:	eb 36                	jmp    80101fa6 <ioapicinit+0x78>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80101f70:	83 ec 0c             	sub    $0xc,%esp
80101f73:	68 1c 67 10 80       	push   $0x8010671c
80101f78:	e8 8e e6 ff ff       	call   8010060b <cprintf>
80101f7d:	83 c4 10             	add    $0x10,%esp
80101f80:	eb e7                	jmp    80101f69 <ioapicinit+0x3b>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80101f82:	8d 53 20             	lea    0x20(%ebx),%edx
80101f85:	81 ca 00 00 01 00    	or     $0x10000,%edx
80101f8b:	8d 74 1b 10          	lea    0x10(%ebx,%ebx,1),%esi
80101f8f:	89 f0                	mov    %esi,%eax
80101f91:	e8 83 ff ff ff       	call   80101f19 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80101f96:	8d 46 01             	lea    0x1(%esi),%eax
80101f99:	ba 00 00 00 00       	mov    $0x0,%edx
80101f9e:	e8 76 ff ff ff       	call   80101f19 <ioapicwrite>
  for(i = 0; i <= maxintr; i++){
80101fa3:	83 c3 01             	add    $0x1,%ebx
80101fa6:	39 fb                	cmp    %edi,%ebx
80101fa8:	7e d8                	jle    80101f82 <ioapicinit+0x54>
  }
}
80101faa:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101fad:	5b                   	pop    %ebx
80101fae:	5e                   	pop    %esi
80101faf:	5f                   	pop    %edi
80101fb0:	5d                   	pop    %ebp
80101fb1:	c3                   	ret    

80101fb2 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80101fb2:	55                   	push   %ebp
80101fb3:	89 e5                	mov    %esp,%ebp
80101fb5:	53                   	push   %ebx
80101fb6:	8b 45 08             	mov    0x8(%ebp),%eax
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80101fb9:	8d 50 20             	lea    0x20(%eax),%edx
80101fbc:	8d 5c 00 10          	lea    0x10(%eax,%eax,1),%ebx
80101fc0:	89 d8                	mov    %ebx,%eax
80101fc2:	e8 52 ff ff ff       	call   80101f19 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80101fc7:	8b 55 0c             	mov    0xc(%ebp),%edx
80101fca:	c1 e2 18             	shl    $0x18,%edx
80101fcd:	8d 43 01             	lea    0x1(%ebx),%eax
80101fd0:	e8 44 ff ff ff       	call   80101f19 <ioapicwrite>
}
80101fd5:	5b                   	pop    %ebx
80101fd6:	5d                   	pop    %ebp
80101fd7:	c3                   	ret    

80101fd8 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80101fd8:	55                   	push   %ebp
80101fd9:	89 e5                	mov    %esp,%ebp
80101fdb:	53                   	push   %ebx
80101fdc:	83 ec 04             	sub    $0x4,%esp
80101fdf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80101fe2:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
80101fe8:	75 4c                	jne    80102036 <kfree+0x5e>
80101fea:	81 fb 88 45 11 80    	cmp    $0x80114588,%ebx
80101ff0:	72 44                	jb     80102036 <kfree+0x5e>
80101ff2:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80101ff8:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80101ffd:	77 37                	ja     80102036 <kfree+0x5e>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80101fff:	83 ec 04             	sub    $0x4,%esp
80102002:	68 00 10 00 00       	push   $0x1000
80102007:	6a 01                	push   $0x1
80102009:	53                   	push   %ebx
8010200a:	e8 17 1d 00 00       	call   80103d26 <memset>

  if(kmem.use_lock)
8010200f:	83 c4 10             	add    $0x10,%esp
80102012:	83 3d d4 36 11 80 00 	cmpl   $0x0,0x801136d4
80102019:	75 28                	jne    80102043 <kfree+0x6b>
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
8010201b:	a1 d8 36 11 80       	mov    0x801136d8,%eax
80102020:	89 03                	mov    %eax,(%ebx)
  kmem.freelist = r;
80102022:	89 1d d8 36 11 80    	mov    %ebx,0x801136d8
  if(kmem.use_lock)
80102028:	83 3d d4 36 11 80 00 	cmpl   $0x0,0x801136d4
8010202f:	75 24                	jne    80102055 <kfree+0x7d>
    release(&kmem.lock);
}
80102031:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102034:	c9                   	leave  
80102035:	c3                   	ret    
    panic("kfree");
80102036:	83 ec 0c             	sub    $0xc,%esp
80102039:	68 4e 67 10 80       	push   $0x8010674e
8010203e:	e8 05 e3 ff ff       	call   80100348 <panic>
    acquire(&kmem.lock);
80102043:	83 ec 0c             	sub    $0xc,%esp
80102046:	68 a0 36 11 80       	push   $0x801136a0
8010204b:	e8 2a 1c 00 00       	call   80103c7a <acquire>
80102050:	83 c4 10             	add    $0x10,%esp
80102053:	eb c6                	jmp    8010201b <kfree+0x43>
    release(&kmem.lock);
80102055:	83 ec 0c             	sub    $0xc,%esp
80102058:	68 a0 36 11 80       	push   $0x801136a0
8010205d:	e8 7d 1c 00 00       	call   80103cdf <release>
80102062:	83 c4 10             	add    $0x10,%esp
}
80102065:	eb ca                	jmp    80102031 <kfree+0x59>

80102067 <freerange>:
{
80102067:	55                   	push   %ebp
80102068:	89 e5                	mov    %esp,%ebp
8010206a:	56                   	push   %esi
8010206b:	53                   	push   %ebx
8010206c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  p = (char*)PGROUNDUP((uint)vstart);
8010206f:	8b 45 08             	mov    0x8(%ebp),%eax
80102072:	05 ff 0f 00 00       	add    $0xfff,%eax
80102077:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010207c:	eb 0e                	jmp    8010208c <freerange+0x25>
    kfree(p);
8010207e:	83 ec 0c             	sub    $0xc,%esp
80102081:	50                   	push   %eax
80102082:	e8 51 ff ff ff       	call   80101fd8 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102087:	83 c4 10             	add    $0x10,%esp
8010208a:	89 f0                	mov    %esi,%eax
8010208c:	8d b0 00 10 00 00    	lea    0x1000(%eax),%esi
80102092:	39 de                	cmp    %ebx,%esi
80102094:	76 e8                	jbe    8010207e <freerange+0x17>
}
80102096:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102099:	5b                   	pop    %ebx
8010209a:	5e                   	pop    %esi
8010209b:	5d                   	pop    %ebp
8010209c:	c3                   	ret    

8010209d <kinit1>:
{
8010209d:	55                   	push   %ebp
8010209e:	89 e5                	mov    %esp,%ebp
801020a0:	83 ec 10             	sub    $0x10,%esp
  initlock(&kmem.lock, "kmem");
801020a3:	68 54 67 10 80       	push   $0x80106754
801020a8:	68 a0 36 11 80       	push   $0x801136a0
801020ad:	e8 8c 1a 00 00       	call   80103b3e <initlock>
  kmem.use_lock = 0;
801020b2:	c7 05 d4 36 11 80 00 	movl   $0x0,0x801136d4
801020b9:	00 00 00 
  freerange(vstart, vend);
801020bc:	83 c4 08             	add    $0x8,%esp
801020bf:	ff 75 0c             	pushl  0xc(%ebp)
801020c2:	ff 75 08             	pushl  0x8(%ebp)
801020c5:	e8 9d ff ff ff       	call   80102067 <freerange>
}
801020ca:	83 c4 10             	add    $0x10,%esp
801020cd:	c9                   	leave  
801020ce:	c3                   	ret    

801020cf <kinit2>:
{
801020cf:	55                   	push   %ebp
801020d0:	89 e5                	mov    %esp,%ebp
801020d2:	83 ec 10             	sub    $0x10,%esp
  freerange(vstart, vend);
801020d5:	ff 75 0c             	pushl  0xc(%ebp)
801020d8:	ff 75 08             	pushl  0x8(%ebp)
801020db:	e8 87 ff ff ff       	call   80102067 <freerange>
  kmem.use_lock = 1;
801020e0:	c7 05 d4 36 11 80 01 	movl   $0x1,0x801136d4
801020e7:	00 00 00 
}
801020ea:	83 c4 10             	add    $0x10,%esp
801020ed:	c9                   	leave  
801020ee:	c3                   	ret    

801020ef <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
801020ef:	55                   	push   %ebp
801020f0:	89 e5                	mov    %esp,%ebp
801020f2:	53                   	push   %ebx
801020f3:	83 ec 04             	sub    $0x4,%esp
  struct run *r;

  if(kmem.use_lock)
801020f6:	83 3d d4 36 11 80 00 	cmpl   $0x0,0x801136d4
801020fd:	75 21                	jne    80102120 <kalloc+0x31>
    acquire(&kmem.lock);
  r = kmem.freelist;
801020ff:	8b 1d d8 36 11 80    	mov    0x801136d8,%ebx
  if(r)
80102105:	85 db                	test   %ebx,%ebx
80102107:	74 07                	je     80102110 <kalloc+0x21>
    kmem.freelist = r->next;
80102109:	8b 03                	mov    (%ebx),%eax
8010210b:	a3 d8 36 11 80       	mov    %eax,0x801136d8
  if(kmem.use_lock)
80102110:	83 3d d4 36 11 80 00 	cmpl   $0x0,0x801136d4
80102117:	75 19                	jne    80102132 <kalloc+0x43>
    release(&kmem.lock);
  return (char*)r;
}
80102119:	89 d8                	mov    %ebx,%eax
8010211b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010211e:	c9                   	leave  
8010211f:	c3                   	ret    
    acquire(&kmem.lock);
80102120:	83 ec 0c             	sub    $0xc,%esp
80102123:	68 a0 36 11 80       	push   $0x801136a0
80102128:	e8 4d 1b 00 00       	call   80103c7a <acquire>
8010212d:	83 c4 10             	add    $0x10,%esp
80102130:	eb cd                	jmp    801020ff <kalloc+0x10>
    release(&kmem.lock);
80102132:	83 ec 0c             	sub    $0xc,%esp
80102135:	68 a0 36 11 80       	push   $0x801136a0
8010213a:	e8 a0 1b 00 00       	call   80103cdf <release>
8010213f:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102142:	eb d5                	jmp    80102119 <kalloc+0x2a>

80102144 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102144:	55                   	push   %ebp
80102145:	89 e5                	mov    %esp,%ebp
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102147:	ba 64 00 00 00       	mov    $0x64,%edx
8010214c:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
8010214d:	a8 01                	test   $0x1,%al
8010214f:	0f 84 b5 00 00 00    	je     8010220a <kbdgetc+0xc6>
80102155:	ba 60 00 00 00       	mov    $0x60,%edx
8010215a:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);
8010215b:	0f b6 d0             	movzbl %al,%edx

  if(data == 0xE0){
8010215e:	81 fa e0 00 00 00    	cmp    $0xe0,%edx
80102164:	74 5c                	je     801021c2 <kbdgetc+0x7e>
    shift |= E0ESC;
    return 0;
  } else if(data & 0x80){
80102166:	84 c0                	test   %al,%al
80102168:	78 66                	js     801021d0 <kbdgetc+0x8c>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
8010216a:	8b 0d b4 95 10 80    	mov    0x801095b4,%ecx
80102170:	f6 c1 40             	test   $0x40,%cl
80102173:	74 0f                	je     80102184 <kbdgetc+0x40>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102175:	83 c8 80             	or     $0xffffff80,%eax
80102178:	0f b6 d0             	movzbl %al,%edx
    shift &= ~E0ESC;
8010217b:	83 e1 bf             	and    $0xffffffbf,%ecx
8010217e:	89 0d b4 95 10 80    	mov    %ecx,0x801095b4
  }

  shift |= shiftcode[data];
80102184:	0f b6 8a 80 68 10 80 	movzbl -0x7fef9780(%edx),%ecx
8010218b:	0b 0d b4 95 10 80    	or     0x801095b4,%ecx
  shift ^= togglecode[data];
80102191:	0f b6 82 80 67 10 80 	movzbl -0x7fef9880(%edx),%eax
80102198:	31 c1                	xor    %eax,%ecx
8010219a:	89 0d b4 95 10 80    	mov    %ecx,0x801095b4
  c = charcode[shift & (CTL | SHIFT)][data];
801021a0:	89 c8                	mov    %ecx,%eax
801021a2:	83 e0 03             	and    $0x3,%eax
801021a5:	8b 04 85 60 67 10 80 	mov    -0x7fef98a0(,%eax,4),%eax
801021ac:	0f b6 04 10          	movzbl (%eax,%edx,1),%eax
  if(shift & CAPSLOCK){
801021b0:	f6 c1 08             	test   $0x8,%cl
801021b3:	74 19                	je     801021ce <kbdgetc+0x8a>
    if('a' <= c && c <= 'z')
801021b5:	8d 50 9f             	lea    -0x61(%eax),%edx
801021b8:	83 fa 19             	cmp    $0x19,%edx
801021bb:	77 40                	ja     801021fd <kbdgetc+0xb9>
      c += 'A' - 'a';
801021bd:	83 e8 20             	sub    $0x20,%eax
801021c0:	eb 0c                	jmp    801021ce <kbdgetc+0x8a>
    shift |= E0ESC;
801021c2:	83 0d b4 95 10 80 40 	orl    $0x40,0x801095b4
    return 0;
801021c9:	b8 00 00 00 00       	mov    $0x0,%eax
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
801021ce:	5d                   	pop    %ebp
801021cf:	c3                   	ret    
    data = (shift & E0ESC ? data : data & 0x7F);
801021d0:	8b 0d b4 95 10 80    	mov    0x801095b4,%ecx
801021d6:	f6 c1 40             	test   $0x40,%cl
801021d9:	75 05                	jne    801021e0 <kbdgetc+0x9c>
801021db:	89 c2                	mov    %eax,%edx
801021dd:	83 e2 7f             	and    $0x7f,%edx
    shift &= ~(shiftcode[data] | E0ESC);
801021e0:	0f b6 82 80 68 10 80 	movzbl -0x7fef9780(%edx),%eax
801021e7:	83 c8 40             	or     $0x40,%eax
801021ea:	0f b6 c0             	movzbl %al,%eax
801021ed:	f7 d0                	not    %eax
801021ef:	21 c8                	and    %ecx,%eax
801021f1:	a3 b4 95 10 80       	mov    %eax,0x801095b4
    return 0;
801021f6:	b8 00 00 00 00       	mov    $0x0,%eax
801021fb:	eb d1                	jmp    801021ce <kbdgetc+0x8a>
    else if('A' <= c && c <= 'Z')
801021fd:	8d 50 bf             	lea    -0x41(%eax),%edx
80102200:	83 fa 19             	cmp    $0x19,%edx
80102203:	77 c9                	ja     801021ce <kbdgetc+0x8a>
      c += 'a' - 'A';
80102205:	83 c0 20             	add    $0x20,%eax
  return c;
80102208:	eb c4                	jmp    801021ce <kbdgetc+0x8a>
    return -1;
8010220a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010220f:	eb bd                	jmp    801021ce <kbdgetc+0x8a>

80102211 <kbdintr>:

void
kbdintr(void)
{
80102211:	55                   	push   %ebp
80102212:	89 e5                	mov    %esp,%ebp
80102214:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
80102217:	68 44 21 10 80       	push   $0x80102144
8010221c:	e8 3e e5 ff ff       	call   8010075f <consoleintr>
}
80102221:	83 c4 10             	add    $0x10,%esp
80102224:	c9                   	leave  
80102225:	c3                   	ret    

80102226 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102226:	55                   	push   %ebp
80102227:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102229:	8b 0d dc 36 11 80    	mov    0x801136dc,%ecx
8010222f:	8d 04 81             	lea    (%ecx,%eax,4),%eax
80102232:	89 10                	mov    %edx,(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102234:	a1 dc 36 11 80       	mov    0x801136dc,%eax
80102239:	8b 40 20             	mov    0x20(%eax),%eax
}
8010223c:	5d                   	pop    %ebp
8010223d:	c3                   	ret    

8010223e <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
8010223e:	55                   	push   %ebp
8010223f:	89 e5                	mov    %esp,%ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102241:	ba 70 00 00 00       	mov    $0x70,%edx
80102246:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102247:	ba 71 00 00 00       	mov    $0x71,%edx
8010224c:	ec                   	in     (%dx),%al
  outb(CMOS_PORT,  reg);
  microdelay(200);

  return inb(CMOS_RETURN);
8010224d:	0f b6 c0             	movzbl %al,%eax
}
80102250:	5d                   	pop    %ebp
80102251:	c3                   	ret    

80102252 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80102252:	55                   	push   %ebp
80102253:	89 e5                	mov    %esp,%ebp
80102255:	53                   	push   %ebx
80102256:	89 c3                	mov    %eax,%ebx
  r->second = cmos_read(SECS);
80102258:	b8 00 00 00 00       	mov    $0x0,%eax
8010225d:	e8 dc ff ff ff       	call   8010223e <cmos_read>
80102262:	89 03                	mov    %eax,(%ebx)
  r->minute = cmos_read(MINS);
80102264:	b8 02 00 00 00       	mov    $0x2,%eax
80102269:	e8 d0 ff ff ff       	call   8010223e <cmos_read>
8010226e:	89 43 04             	mov    %eax,0x4(%ebx)
  r->hour   = cmos_read(HOURS);
80102271:	b8 04 00 00 00       	mov    $0x4,%eax
80102276:	e8 c3 ff ff ff       	call   8010223e <cmos_read>
8010227b:	89 43 08             	mov    %eax,0x8(%ebx)
  r->day    = cmos_read(DAY);
8010227e:	b8 07 00 00 00       	mov    $0x7,%eax
80102283:	e8 b6 ff ff ff       	call   8010223e <cmos_read>
80102288:	89 43 0c             	mov    %eax,0xc(%ebx)
  r->month  = cmos_read(MONTH);
8010228b:	b8 08 00 00 00       	mov    $0x8,%eax
80102290:	e8 a9 ff ff ff       	call   8010223e <cmos_read>
80102295:	89 43 10             	mov    %eax,0x10(%ebx)
  r->year   = cmos_read(YEAR);
80102298:	b8 09 00 00 00       	mov    $0x9,%eax
8010229d:	e8 9c ff ff ff       	call   8010223e <cmos_read>
801022a2:	89 43 14             	mov    %eax,0x14(%ebx)
}
801022a5:	5b                   	pop    %ebx
801022a6:	5d                   	pop    %ebp
801022a7:	c3                   	ret    

801022a8 <lapicinit>:
  if(!lapic)
801022a8:	83 3d dc 36 11 80 00 	cmpl   $0x0,0x801136dc
801022af:	0f 84 fb 00 00 00    	je     801023b0 <lapicinit+0x108>
{
801022b5:	55                   	push   %ebp
801022b6:	89 e5                	mov    %esp,%ebp
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801022b8:	ba 3f 01 00 00       	mov    $0x13f,%edx
801022bd:	b8 3c 00 00 00       	mov    $0x3c,%eax
801022c2:	e8 5f ff ff ff       	call   80102226 <lapicw>
  lapicw(TDCR, X1);
801022c7:	ba 0b 00 00 00       	mov    $0xb,%edx
801022cc:	b8 f8 00 00 00       	mov    $0xf8,%eax
801022d1:	e8 50 ff ff ff       	call   80102226 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
801022d6:	ba 20 00 02 00       	mov    $0x20020,%edx
801022db:	b8 c8 00 00 00       	mov    $0xc8,%eax
801022e0:	e8 41 ff ff ff       	call   80102226 <lapicw>
  lapicw(TICR, 1000000);
801022e5:	ba 40 42 0f 00       	mov    $0xf4240,%edx
801022ea:	b8 e0 00 00 00       	mov    $0xe0,%eax
801022ef:	e8 32 ff ff ff       	call   80102226 <lapicw>
  lapicw(LINT0, MASKED);
801022f4:	ba 00 00 01 00       	mov    $0x10000,%edx
801022f9:	b8 d4 00 00 00       	mov    $0xd4,%eax
801022fe:	e8 23 ff ff ff       	call   80102226 <lapicw>
  lapicw(LINT1, MASKED);
80102303:	ba 00 00 01 00       	mov    $0x10000,%edx
80102308:	b8 d8 00 00 00       	mov    $0xd8,%eax
8010230d:	e8 14 ff ff ff       	call   80102226 <lapicw>
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102312:	a1 dc 36 11 80       	mov    0x801136dc,%eax
80102317:	8b 40 30             	mov    0x30(%eax),%eax
8010231a:	c1 e8 10             	shr    $0x10,%eax
8010231d:	3c 03                	cmp    $0x3,%al
8010231f:	77 7b                	ja     8010239c <lapicinit+0xf4>
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102321:	ba 33 00 00 00       	mov    $0x33,%edx
80102326:	b8 dc 00 00 00       	mov    $0xdc,%eax
8010232b:	e8 f6 fe ff ff       	call   80102226 <lapicw>
  lapicw(ESR, 0);
80102330:	ba 00 00 00 00       	mov    $0x0,%edx
80102335:	b8 a0 00 00 00       	mov    $0xa0,%eax
8010233a:	e8 e7 fe ff ff       	call   80102226 <lapicw>
  lapicw(ESR, 0);
8010233f:	ba 00 00 00 00       	mov    $0x0,%edx
80102344:	b8 a0 00 00 00       	mov    $0xa0,%eax
80102349:	e8 d8 fe ff ff       	call   80102226 <lapicw>
  lapicw(EOI, 0);
8010234e:	ba 00 00 00 00       	mov    $0x0,%edx
80102353:	b8 2c 00 00 00       	mov    $0x2c,%eax
80102358:	e8 c9 fe ff ff       	call   80102226 <lapicw>
  lapicw(ICRHI, 0);
8010235d:	ba 00 00 00 00       	mov    $0x0,%edx
80102362:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102367:	e8 ba fe ff ff       	call   80102226 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
8010236c:	ba 00 85 08 00       	mov    $0x88500,%edx
80102371:	b8 c0 00 00 00       	mov    $0xc0,%eax
80102376:	e8 ab fe ff ff       	call   80102226 <lapicw>
  while(lapic[ICRLO] & DELIVS)
8010237b:	a1 dc 36 11 80       	mov    0x801136dc,%eax
80102380:	8b 80 00 03 00 00    	mov    0x300(%eax),%eax
80102386:	f6 c4 10             	test   $0x10,%ah
80102389:	75 f0                	jne    8010237b <lapicinit+0xd3>
  lapicw(TPR, 0);
8010238b:	ba 00 00 00 00       	mov    $0x0,%edx
80102390:	b8 20 00 00 00       	mov    $0x20,%eax
80102395:	e8 8c fe ff ff       	call   80102226 <lapicw>
}
8010239a:	5d                   	pop    %ebp
8010239b:	c3                   	ret    
    lapicw(PCINT, MASKED);
8010239c:	ba 00 00 01 00       	mov    $0x10000,%edx
801023a1:	b8 d0 00 00 00       	mov    $0xd0,%eax
801023a6:	e8 7b fe ff ff       	call   80102226 <lapicw>
801023ab:	e9 71 ff ff ff       	jmp    80102321 <lapicinit+0x79>
801023b0:	f3 c3                	repz ret 

801023b2 <lapicid>:
{
801023b2:	55                   	push   %ebp
801023b3:	89 e5                	mov    %esp,%ebp
  if (!lapic)
801023b5:	a1 dc 36 11 80       	mov    0x801136dc,%eax
801023ba:	85 c0                	test   %eax,%eax
801023bc:	74 08                	je     801023c6 <lapicid+0x14>
  return lapic[ID] >> 24;
801023be:	8b 40 20             	mov    0x20(%eax),%eax
801023c1:	c1 e8 18             	shr    $0x18,%eax
}
801023c4:	5d                   	pop    %ebp
801023c5:	c3                   	ret    
    return 0;
801023c6:	b8 00 00 00 00       	mov    $0x0,%eax
801023cb:	eb f7                	jmp    801023c4 <lapicid+0x12>

801023cd <lapiceoi>:
  if(lapic)
801023cd:	83 3d dc 36 11 80 00 	cmpl   $0x0,0x801136dc
801023d4:	74 14                	je     801023ea <lapiceoi+0x1d>
{
801023d6:	55                   	push   %ebp
801023d7:	89 e5                	mov    %esp,%ebp
    lapicw(EOI, 0);
801023d9:	ba 00 00 00 00       	mov    $0x0,%edx
801023de:	b8 2c 00 00 00       	mov    $0x2c,%eax
801023e3:	e8 3e fe ff ff       	call   80102226 <lapicw>
}
801023e8:	5d                   	pop    %ebp
801023e9:	c3                   	ret    
801023ea:	f3 c3                	repz ret 

801023ec <microdelay>:
{
801023ec:	55                   	push   %ebp
801023ed:	89 e5                	mov    %esp,%ebp
}
801023ef:	5d                   	pop    %ebp
801023f0:	c3                   	ret    

801023f1 <lapicstartap>:
{
801023f1:	55                   	push   %ebp
801023f2:	89 e5                	mov    %esp,%ebp
801023f4:	57                   	push   %edi
801023f5:	56                   	push   %esi
801023f6:	53                   	push   %ebx
801023f7:	8b 75 08             	mov    0x8(%ebp),%esi
801023fa:	8b 7d 0c             	mov    0xc(%ebp),%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801023fd:	b8 0f 00 00 00       	mov    $0xf,%eax
80102402:	ba 70 00 00 00       	mov    $0x70,%edx
80102407:	ee                   	out    %al,(%dx)
80102408:	b8 0a 00 00 00       	mov    $0xa,%eax
8010240d:	ba 71 00 00 00       	mov    $0x71,%edx
80102412:	ee                   	out    %al,(%dx)
  wrv[0] = 0;
80102413:	66 c7 05 67 04 00 80 	movw   $0x0,0x80000467
8010241a:	00 00 
  wrv[1] = addr >> 4;
8010241c:	89 f8                	mov    %edi,%eax
8010241e:	c1 e8 04             	shr    $0x4,%eax
80102421:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapicw(ICRHI, apicid<<24);
80102427:	c1 e6 18             	shl    $0x18,%esi
8010242a:	89 f2                	mov    %esi,%edx
8010242c:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102431:	e8 f0 fd ff ff       	call   80102226 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102436:	ba 00 c5 00 00       	mov    $0xc500,%edx
8010243b:	b8 c0 00 00 00       	mov    $0xc0,%eax
80102440:	e8 e1 fd ff ff       	call   80102226 <lapicw>
  lapicw(ICRLO, INIT | LEVEL);
80102445:	ba 00 85 00 00       	mov    $0x8500,%edx
8010244a:	b8 c0 00 00 00       	mov    $0xc0,%eax
8010244f:	e8 d2 fd ff ff       	call   80102226 <lapicw>
  for(i = 0; i < 2; i++){
80102454:	bb 00 00 00 00       	mov    $0x0,%ebx
80102459:	eb 21                	jmp    8010247c <lapicstartap+0x8b>
    lapicw(ICRHI, apicid<<24);
8010245b:	89 f2                	mov    %esi,%edx
8010245d:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102462:	e8 bf fd ff ff       	call   80102226 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80102467:	89 fa                	mov    %edi,%edx
80102469:	c1 ea 0c             	shr    $0xc,%edx
8010246c:	80 ce 06             	or     $0x6,%dh
8010246f:	b8 c0 00 00 00       	mov    $0xc0,%eax
80102474:	e8 ad fd ff ff       	call   80102226 <lapicw>
  for(i = 0; i < 2; i++){
80102479:	83 c3 01             	add    $0x1,%ebx
8010247c:	83 fb 01             	cmp    $0x1,%ebx
8010247f:	7e da                	jle    8010245b <lapicstartap+0x6a>
}
80102481:	5b                   	pop    %ebx
80102482:	5e                   	pop    %esi
80102483:	5f                   	pop    %edi
80102484:	5d                   	pop    %ebp
80102485:	c3                   	ret    

80102486 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80102486:	55                   	push   %ebp
80102487:	89 e5                	mov    %esp,%ebp
80102489:	57                   	push   %edi
8010248a:	56                   	push   %esi
8010248b:	53                   	push   %ebx
8010248c:	83 ec 3c             	sub    $0x3c,%esp
8010248f:	8b 75 08             	mov    0x8(%ebp),%esi
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102492:	b8 0b 00 00 00       	mov    $0xb,%eax
80102497:	e8 a2 fd ff ff       	call   8010223e <cmos_read>

  bcd = (sb & (1 << 2)) == 0;
8010249c:	83 e0 04             	and    $0x4,%eax
8010249f:	89 c7                	mov    %eax,%edi

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
801024a1:	8d 45 d0             	lea    -0x30(%ebp),%eax
801024a4:	e8 a9 fd ff ff       	call   80102252 <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
801024a9:	b8 0a 00 00 00       	mov    $0xa,%eax
801024ae:	e8 8b fd ff ff       	call   8010223e <cmos_read>
801024b3:	a8 80                	test   $0x80,%al
801024b5:	75 ea                	jne    801024a1 <cmostime+0x1b>
        continue;
    fill_rtcdate(&t2);
801024b7:	8d 5d b8             	lea    -0x48(%ebp),%ebx
801024ba:	89 d8                	mov    %ebx,%eax
801024bc:	e8 91 fd ff ff       	call   80102252 <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801024c1:	83 ec 04             	sub    $0x4,%esp
801024c4:	6a 18                	push   $0x18
801024c6:	53                   	push   %ebx
801024c7:	8d 45 d0             	lea    -0x30(%ebp),%eax
801024ca:	50                   	push   %eax
801024cb:	e8 9c 18 00 00       	call   80103d6c <memcmp>
801024d0:	83 c4 10             	add    $0x10,%esp
801024d3:	85 c0                	test   %eax,%eax
801024d5:	75 ca                	jne    801024a1 <cmostime+0x1b>
      break;
  }

  // convert
  if(bcd) {
801024d7:	85 ff                	test   %edi,%edi
801024d9:	0f 85 84 00 00 00    	jne    80102563 <cmostime+0xdd>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801024df:	8b 55 d0             	mov    -0x30(%ebp),%edx
801024e2:	89 d0                	mov    %edx,%eax
801024e4:	c1 e8 04             	shr    $0x4,%eax
801024e7:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801024ea:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801024ed:	83 e2 0f             	and    $0xf,%edx
801024f0:	01 d0                	add    %edx,%eax
801024f2:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(minute);
801024f5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
801024f8:	89 d0                	mov    %edx,%eax
801024fa:	c1 e8 04             	shr    $0x4,%eax
801024fd:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102500:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102503:	83 e2 0f             	and    $0xf,%edx
80102506:	01 d0                	add    %edx,%eax
80102508:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(hour  );
8010250b:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010250e:	89 d0                	mov    %edx,%eax
80102510:	c1 e8 04             	shr    $0x4,%eax
80102513:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102516:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102519:	83 e2 0f             	and    $0xf,%edx
8010251c:	01 d0                	add    %edx,%eax
8010251e:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(day   );
80102521:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102524:	89 d0                	mov    %edx,%eax
80102526:	c1 e8 04             	shr    $0x4,%eax
80102529:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
8010252c:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
8010252f:	83 e2 0f             	and    $0xf,%edx
80102532:	01 d0                	add    %edx,%eax
80102534:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(month );
80102537:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010253a:	89 d0                	mov    %edx,%eax
8010253c:	c1 e8 04             	shr    $0x4,%eax
8010253f:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102542:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102545:	83 e2 0f             	and    $0xf,%edx
80102548:	01 d0                	add    %edx,%eax
8010254a:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(year  );
8010254d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102550:	89 d0                	mov    %edx,%eax
80102552:	c1 e8 04             	shr    $0x4,%eax
80102555:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102558:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
8010255b:	83 e2 0f             	and    $0xf,%edx
8010255e:	01 d0                	add    %edx,%eax
80102560:	89 45 e4             	mov    %eax,-0x1c(%ebp)
#undef     CONV
  }

  *r = t1;
80102563:	8b 45 d0             	mov    -0x30(%ebp),%eax
80102566:	89 06                	mov    %eax,(%esi)
80102568:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010256b:	89 46 04             	mov    %eax,0x4(%esi)
8010256e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102571:	89 46 08             	mov    %eax,0x8(%esi)
80102574:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102577:	89 46 0c             	mov    %eax,0xc(%esi)
8010257a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010257d:	89 46 10             	mov    %eax,0x10(%esi)
80102580:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102583:	89 46 14             	mov    %eax,0x14(%esi)
  r->year += 2000;
80102586:	81 46 14 d0 07 00 00 	addl   $0x7d0,0x14(%esi)
}
8010258d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102590:	5b                   	pop    %ebx
80102591:	5e                   	pop    %esi
80102592:	5f                   	pop    %edi
80102593:	5d                   	pop    %ebp
80102594:	c3                   	ret    

80102595 <read_head>:
}

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80102595:	55                   	push   %ebp
80102596:	89 e5                	mov    %esp,%ebp
80102598:	53                   	push   %ebx
80102599:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
8010259c:	ff 35 14 37 11 80    	pushl  0x80113714
801025a2:	ff 35 24 37 11 80    	pushl  0x80113724
801025a8:	e8 bf db ff ff       	call   8010016c <bread>
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
801025ad:	8b 58 5c             	mov    0x5c(%eax),%ebx
801025b0:	89 1d 28 37 11 80    	mov    %ebx,0x80113728
  for (i = 0; i < log.lh.n; i++) {
801025b6:	83 c4 10             	add    $0x10,%esp
801025b9:	ba 00 00 00 00       	mov    $0x0,%edx
801025be:	eb 0e                	jmp    801025ce <read_head+0x39>
    log.lh.block[i] = lh->block[i];
801025c0:	8b 4c 90 60          	mov    0x60(%eax,%edx,4),%ecx
801025c4:	89 0c 95 2c 37 11 80 	mov    %ecx,-0x7feec8d4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801025cb:	83 c2 01             	add    $0x1,%edx
801025ce:	39 d3                	cmp    %edx,%ebx
801025d0:	7f ee                	jg     801025c0 <read_head+0x2b>
  }
  brelse(buf);
801025d2:	83 ec 0c             	sub    $0xc,%esp
801025d5:	50                   	push   %eax
801025d6:	e8 fa db ff ff       	call   801001d5 <brelse>
}
801025db:	83 c4 10             	add    $0x10,%esp
801025de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801025e1:	c9                   	leave  
801025e2:	c3                   	ret    

801025e3 <install_trans>:
{
801025e3:	55                   	push   %ebp
801025e4:	89 e5                	mov    %esp,%ebp
801025e6:	57                   	push   %edi
801025e7:	56                   	push   %esi
801025e8:	53                   	push   %ebx
801025e9:	83 ec 0c             	sub    $0xc,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
801025ec:	bb 00 00 00 00       	mov    $0x0,%ebx
801025f1:	eb 66                	jmp    80102659 <install_trans+0x76>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801025f3:	89 d8                	mov    %ebx,%eax
801025f5:	03 05 14 37 11 80    	add    0x80113714,%eax
801025fb:	83 c0 01             	add    $0x1,%eax
801025fe:	83 ec 08             	sub    $0x8,%esp
80102601:	50                   	push   %eax
80102602:	ff 35 24 37 11 80    	pushl  0x80113724
80102608:	e8 5f db ff ff       	call   8010016c <bread>
8010260d:	89 c7                	mov    %eax,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
8010260f:	83 c4 08             	add    $0x8,%esp
80102612:	ff 34 9d 2c 37 11 80 	pushl  -0x7feec8d4(,%ebx,4)
80102619:	ff 35 24 37 11 80    	pushl  0x80113724
8010261f:	e8 48 db ff ff       	call   8010016c <bread>
80102624:	89 c6                	mov    %eax,%esi
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102626:	8d 57 5c             	lea    0x5c(%edi),%edx
80102629:	8d 40 5c             	lea    0x5c(%eax),%eax
8010262c:	83 c4 0c             	add    $0xc,%esp
8010262f:	68 00 02 00 00       	push   $0x200
80102634:	52                   	push   %edx
80102635:	50                   	push   %eax
80102636:	e8 66 17 00 00       	call   80103da1 <memmove>
    bwrite(dbuf);  // write dst to disk
8010263b:	89 34 24             	mov    %esi,(%esp)
8010263e:	e8 57 db ff ff       	call   8010019a <bwrite>
    brelse(lbuf);
80102643:	89 3c 24             	mov    %edi,(%esp)
80102646:	e8 8a db ff ff       	call   801001d5 <brelse>
    brelse(dbuf);
8010264b:	89 34 24             	mov    %esi,(%esp)
8010264e:	e8 82 db ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102653:	83 c3 01             	add    $0x1,%ebx
80102656:	83 c4 10             	add    $0x10,%esp
80102659:	39 1d 28 37 11 80    	cmp    %ebx,0x80113728
8010265f:	7f 92                	jg     801025f3 <install_trans+0x10>
}
80102661:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102664:	5b                   	pop    %ebx
80102665:	5e                   	pop    %esi
80102666:	5f                   	pop    %edi
80102667:	5d                   	pop    %ebp
80102668:	c3                   	ret    

80102669 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102669:	55                   	push   %ebp
8010266a:	89 e5                	mov    %esp,%ebp
8010266c:	53                   	push   %ebx
8010266d:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
80102670:	ff 35 14 37 11 80    	pushl  0x80113714
80102676:	ff 35 24 37 11 80    	pushl  0x80113724
8010267c:	e8 eb da ff ff       	call   8010016c <bread>
80102681:	89 c3                	mov    %eax,%ebx
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
80102683:	8b 0d 28 37 11 80    	mov    0x80113728,%ecx
80102689:	89 48 5c             	mov    %ecx,0x5c(%eax)
  for (i = 0; i < log.lh.n; i++) {
8010268c:	83 c4 10             	add    $0x10,%esp
8010268f:	b8 00 00 00 00       	mov    $0x0,%eax
80102694:	eb 0e                	jmp    801026a4 <write_head+0x3b>
    hb->block[i] = log.lh.block[i];
80102696:	8b 14 85 2c 37 11 80 	mov    -0x7feec8d4(,%eax,4),%edx
8010269d:	89 54 83 60          	mov    %edx,0x60(%ebx,%eax,4)
  for (i = 0; i < log.lh.n; i++) {
801026a1:	83 c0 01             	add    $0x1,%eax
801026a4:	39 c1                	cmp    %eax,%ecx
801026a6:	7f ee                	jg     80102696 <write_head+0x2d>
  }
  bwrite(buf);
801026a8:	83 ec 0c             	sub    $0xc,%esp
801026ab:	53                   	push   %ebx
801026ac:	e8 e9 da ff ff       	call   8010019a <bwrite>
  brelse(buf);
801026b1:	89 1c 24             	mov    %ebx,(%esp)
801026b4:	e8 1c db ff ff       	call   801001d5 <brelse>
}
801026b9:	83 c4 10             	add    $0x10,%esp
801026bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801026bf:	c9                   	leave  
801026c0:	c3                   	ret    

801026c1 <recover_from_log>:

static void
recover_from_log(void)
{
801026c1:	55                   	push   %ebp
801026c2:	89 e5                	mov    %esp,%ebp
801026c4:	83 ec 08             	sub    $0x8,%esp
  read_head();
801026c7:	e8 c9 fe ff ff       	call   80102595 <read_head>
  install_trans(); // if committed, copy from log to disk
801026cc:	e8 12 ff ff ff       	call   801025e3 <install_trans>
  log.lh.n = 0;
801026d1:	c7 05 28 37 11 80 00 	movl   $0x0,0x80113728
801026d8:	00 00 00 
  write_head(); // clear the log
801026db:	e8 89 ff ff ff       	call   80102669 <write_head>
}
801026e0:	c9                   	leave  
801026e1:	c3                   	ret    

801026e2 <write_log>:
}

// Copy modified blocks from cache to log.
static void
write_log(void)
{
801026e2:	55                   	push   %ebp
801026e3:	89 e5                	mov    %esp,%ebp
801026e5:	57                   	push   %edi
801026e6:	56                   	push   %esi
801026e7:	53                   	push   %ebx
801026e8:	83 ec 0c             	sub    $0xc,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801026eb:	bb 00 00 00 00       	mov    $0x0,%ebx
801026f0:	eb 66                	jmp    80102758 <write_log+0x76>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801026f2:	89 d8                	mov    %ebx,%eax
801026f4:	03 05 14 37 11 80    	add    0x80113714,%eax
801026fa:	83 c0 01             	add    $0x1,%eax
801026fd:	83 ec 08             	sub    $0x8,%esp
80102700:	50                   	push   %eax
80102701:	ff 35 24 37 11 80    	pushl  0x80113724
80102707:	e8 60 da ff ff       	call   8010016c <bread>
8010270c:	89 c6                	mov    %eax,%esi
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
8010270e:	83 c4 08             	add    $0x8,%esp
80102711:	ff 34 9d 2c 37 11 80 	pushl  -0x7feec8d4(,%ebx,4)
80102718:	ff 35 24 37 11 80    	pushl  0x80113724
8010271e:	e8 49 da ff ff       	call   8010016c <bread>
80102723:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
80102725:	8d 50 5c             	lea    0x5c(%eax),%edx
80102728:	8d 46 5c             	lea    0x5c(%esi),%eax
8010272b:	83 c4 0c             	add    $0xc,%esp
8010272e:	68 00 02 00 00       	push   $0x200
80102733:	52                   	push   %edx
80102734:	50                   	push   %eax
80102735:	e8 67 16 00 00       	call   80103da1 <memmove>
    bwrite(to);  // write the log
8010273a:	89 34 24             	mov    %esi,(%esp)
8010273d:	e8 58 da ff ff       	call   8010019a <bwrite>
    brelse(from);
80102742:	89 3c 24             	mov    %edi,(%esp)
80102745:	e8 8b da ff ff       	call   801001d5 <brelse>
    brelse(to);
8010274a:	89 34 24             	mov    %esi,(%esp)
8010274d:	e8 83 da ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102752:	83 c3 01             	add    $0x1,%ebx
80102755:	83 c4 10             	add    $0x10,%esp
80102758:	39 1d 28 37 11 80    	cmp    %ebx,0x80113728
8010275e:	7f 92                	jg     801026f2 <write_log+0x10>
  }
}
80102760:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102763:	5b                   	pop    %ebx
80102764:	5e                   	pop    %esi
80102765:	5f                   	pop    %edi
80102766:	5d                   	pop    %ebp
80102767:	c3                   	ret    

80102768 <commit>:

static void
commit()
{
  if (log.lh.n > 0) {
80102768:	83 3d 28 37 11 80 00 	cmpl   $0x0,0x80113728
8010276f:	7e 26                	jle    80102797 <commit+0x2f>
{
80102771:	55                   	push   %ebp
80102772:	89 e5                	mov    %esp,%ebp
80102774:	83 ec 08             	sub    $0x8,%esp
    write_log();     // Write modified blocks from cache to log
80102777:	e8 66 ff ff ff       	call   801026e2 <write_log>
    write_head();    // Write header to disk -- the real commit
8010277c:	e8 e8 fe ff ff       	call   80102669 <write_head>
    install_trans(); // Now install writes to home locations
80102781:	e8 5d fe ff ff       	call   801025e3 <install_trans>
    log.lh.n = 0;
80102786:	c7 05 28 37 11 80 00 	movl   $0x0,0x80113728
8010278d:	00 00 00 
    write_head();    // Erase the transaction from the log
80102790:	e8 d4 fe ff ff       	call   80102669 <write_head>
  }
}
80102795:	c9                   	leave  
80102796:	c3                   	ret    
80102797:	f3 c3                	repz ret 

80102799 <initlog>:
{
80102799:	55                   	push   %ebp
8010279a:	89 e5                	mov    %esp,%ebp
8010279c:	53                   	push   %ebx
8010279d:	83 ec 2c             	sub    $0x2c,%esp
801027a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
801027a3:	68 80 69 10 80       	push   $0x80106980
801027a8:	68 e0 36 11 80       	push   $0x801136e0
801027ad:	e8 8c 13 00 00       	call   80103b3e <initlock>
  readsb(dev, &sb);
801027b2:	83 c4 08             	add    $0x8,%esp
801027b5:	8d 45 dc             	lea    -0x24(%ebp),%eax
801027b8:	50                   	push   %eax
801027b9:	53                   	push   %ebx
801027ba:	e8 ab ea ff ff       	call   8010126a <readsb>
  log.start = sb.logstart;
801027bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801027c2:	a3 14 37 11 80       	mov    %eax,0x80113714
  log.size = sb.nlog;
801027c7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801027ca:	a3 18 37 11 80       	mov    %eax,0x80113718
  log.dev = dev;
801027cf:	89 1d 24 37 11 80    	mov    %ebx,0x80113724
  recover_from_log();
801027d5:	e8 e7 fe ff ff       	call   801026c1 <recover_from_log>
}
801027da:	83 c4 10             	add    $0x10,%esp
801027dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801027e0:	c9                   	leave  
801027e1:	c3                   	ret    

801027e2 <begin_op>:
{
801027e2:	55                   	push   %ebp
801027e3:	89 e5                	mov    %esp,%ebp
801027e5:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
801027e8:	68 e0 36 11 80       	push   $0x801136e0
801027ed:	e8 88 14 00 00       	call   80103c7a <acquire>
801027f2:	83 c4 10             	add    $0x10,%esp
801027f5:	eb 15                	jmp    8010280c <begin_op+0x2a>
      sleep(&log, &log.lock);
801027f7:	83 ec 08             	sub    $0x8,%esp
801027fa:	68 e0 36 11 80       	push   $0x801136e0
801027ff:	68 e0 36 11 80       	push   $0x801136e0
80102804:	e8 06 0f 00 00       	call   8010370f <sleep>
80102809:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
8010280c:	83 3d 20 37 11 80 00 	cmpl   $0x0,0x80113720
80102813:	75 e2                	jne    801027f7 <begin_op+0x15>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80102815:	a1 1c 37 11 80       	mov    0x8011371c,%eax
8010281a:	83 c0 01             	add    $0x1,%eax
8010281d:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102820:	8d 14 09             	lea    (%ecx,%ecx,1),%edx
80102823:	03 15 28 37 11 80    	add    0x80113728,%edx
80102829:	83 fa 1e             	cmp    $0x1e,%edx
8010282c:	7e 17                	jle    80102845 <begin_op+0x63>
      sleep(&log, &log.lock);
8010282e:	83 ec 08             	sub    $0x8,%esp
80102831:	68 e0 36 11 80       	push   $0x801136e0
80102836:	68 e0 36 11 80       	push   $0x801136e0
8010283b:	e8 cf 0e 00 00       	call   8010370f <sleep>
80102840:	83 c4 10             	add    $0x10,%esp
80102843:	eb c7                	jmp    8010280c <begin_op+0x2a>
      log.outstanding += 1;
80102845:	a3 1c 37 11 80       	mov    %eax,0x8011371c
      release(&log.lock);
8010284a:	83 ec 0c             	sub    $0xc,%esp
8010284d:	68 e0 36 11 80       	push   $0x801136e0
80102852:	e8 88 14 00 00       	call   80103cdf <release>
}
80102857:	83 c4 10             	add    $0x10,%esp
8010285a:	c9                   	leave  
8010285b:	c3                   	ret    

8010285c <end_op>:
{
8010285c:	55                   	push   %ebp
8010285d:	89 e5                	mov    %esp,%ebp
8010285f:	53                   	push   %ebx
80102860:	83 ec 10             	sub    $0x10,%esp
  acquire(&log.lock);
80102863:	68 e0 36 11 80       	push   $0x801136e0
80102868:	e8 0d 14 00 00       	call   80103c7a <acquire>
  log.outstanding -= 1;
8010286d:	a1 1c 37 11 80       	mov    0x8011371c,%eax
80102872:	83 e8 01             	sub    $0x1,%eax
80102875:	a3 1c 37 11 80       	mov    %eax,0x8011371c
  if(log.committing)
8010287a:	8b 1d 20 37 11 80    	mov    0x80113720,%ebx
80102880:	83 c4 10             	add    $0x10,%esp
80102883:	85 db                	test   %ebx,%ebx
80102885:	75 2c                	jne    801028b3 <end_op+0x57>
  if(log.outstanding == 0){
80102887:	85 c0                	test   %eax,%eax
80102889:	75 35                	jne    801028c0 <end_op+0x64>
    log.committing = 1;
8010288b:	c7 05 20 37 11 80 01 	movl   $0x1,0x80113720
80102892:	00 00 00 
    do_commit = 1;
80102895:	bb 01 00 00 00       	mov    $0x1,%ebx
  release(&log.lock);
8010289a:	83 ec 0c             	sub    $0xc,%esp
8010289d:	68 e0 36 11 80       	push   $0x801136e0
801028a2:	e8 38 14 00 00       	call   80103cdf <release>
  if(do_commit){
801028a7:	83 c4 10             	add    $0x10,%esp
801028aa:	85 db                	test   %ebx,%ebx
801028ac:	75 24                	jne    801028d2 <end_op+0x76>
}
801028ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801028b1:	c9                   	leave  
801028b2:	c3                   	ret    
    panic("log.committing");
801028b3:	83 ec 0c             	sub    $0xc,%esp
801028b6:	68 84 69 10 80       	push   $0x80106984
801028bb:	e8 88 da ff ff       	call   80100348 <panic>
    wakeup(&log);
801028c0:	83 ec 0c             	sub    $0xc,%esp
801028c3:	68 e0 36 11 80       	push   $0x801136e0
801028c8:	e8 a6 0f 00 00       	call   80103873 <wakeup>
801028cd:	83 c4 10             	add    $0x10,%esp
801028d0:	eb c8                	jmp    8010289a <end_op+0x3e>
    commit();
801028d2:	e8 91 fe ff ff       	call   80102768 <commit>
    acquire(&log.lock);
801028d7:	83 ec 0c             	sub    $0xc,%esp
801028da:	68 e0 36 11 80       	push   $0x801136e0
801028df:	e8 96 13 00 00       	call   80103c7a <acquire>
    log.committing = 0;
801028e4:	c7 05 20 37 11 80 00 	movl   $0x0,0x80113720
801028eb:	00 00 00 
    wakeup(&log);
801028ee:	c7 04 24 e0 36 11 80 	movl   $0x801136e0,(%esp)
801028f5:	e8 79 0f 00 00       	call   80103873 <wakeup>
    release(&log.lock);
801028fa:	c7 04 24 e0 36 11 80 	movl   $0x801136e0,(%esp)
80102901:	e8 d9 13 00 00       	call   80103cdf <release>
80102906:	83 c4 10             	add    $0x10,%esp
}
80102909:	eb a3                	jmp    801028ae <end_op+0x52>

8010290b <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
8010290b:	55                   	push   %ebp
8010290c:	89 e5                	mov    %esp,%ebp
8010290e:	53                   	push   %ebx
8010290f:	83 ec 04             	sub    $0x4,%esp
80102912:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80102915:	8b 15 28 37 11 80    	mov    0x80113728,%edx
8010291b:	83 fa 1d             	cmp    $0x1d,%edx
8010291e:	7f 45                	jg     80102965 <log_write+0x5a>
80102920:	a1 18 37 11 80       	mov    0x80113718,%eax
80102925:	83 e8 01             	sub    $0x1,%eax
80102928:	39 c2                	cmp    %eax,%edx
8010292a:	7d 39                	jge    80102965 <log_write+0x5a>
    panic("too big a transaction");
  if (log.outstanding < 1)
8010292c:	83 3d 1c 37 11 80 00 	cmpl   $0x0,0x8011371c
80102933:	7e 3d                	jle    80102972 <log_write+0x67>
    panic("log_write outside of trans");

  acquire(&log.lock);
80102935:	83 ec 0c             	sub    $0xc,%esp
80102938:	68 e0 36 11 80       	push   $0x801136e0
8010293d:	e8 38 13 00 00       	call   80103c7a <acquire>
  for (i = 0; i < log.lh.n; i++) {
80102942:	83 c4 10             	add    $0x10,%esp
80102945:	b8 00 00 00 00       	mov    $0x0,%eax
8010294a:	8b 15 28 37 11 80    	mov    0x80113728,%edx
80102950:	39 c2                	cmp    %eax,%edx
80102952:	7e 2b                	jle    8010297f <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80102954:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102957:	39 0c 85 2c 37 11 80 	cmp    %ecx,-0x7feec8d4(,%eax,4)
8010295e:	74 1f                	je     8010297f <log_write+0x74>
  for (i = 0; i < log.lh.n; i++) {
80102960:	83 c0 01             	add    $0x1,%eax
80102963:	eb e5                	jmp    8010294a <log_write+0x3f>
    panic("too big a transaction");
80102965:	83 ec 0c             	sub    $0xc,%esp
80102968:	68 93 69 10 80       	push   $0x80106993
8010296d:	e8 d6 d9 ff ff       	call   80100348 <panic>
    panic("log_write outside of trans");
80102972:	83 ec 0c             	sub    $0xc,%esp
80102975:	68 a9 69 10 80       	push   $0x801069a9
8010297a:	e8 c9 d9 ff ff       	call   80100348 <panic>
      break;
  }
  log.lh.block[i] = b->blockno;
8010297f:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102982:	89 0c 85 2c 37 11 80 	mov    %ecx,-0x7feec8d4(,%eax,4)
  if (i == log.lh.n)
80102989:	39 c2                	cmp    %eax,%edx
8010298b:	74 18                	je     801029a5 <log_write+0x9a>
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
8010298d:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
80102990:	83 ec 0c             	sub    $0xc,%esp
80102993:	68 e0 36 11 80       	push   $0x801136e0
80102998:	e8 42 13 00 00       	call   80103cdf <release>
}
8010299d:	83 c4 10             	add    $0x10,%esp
801029a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801029a3:	c9                   	leave  
801029a4:	c3                   	ret    
    log.lh.n++;
801029a5:	83 c2 01             	add    $0x1,%edx
801029a8:	89 15 28 37 11 80    	mov    %edx,0x80113728
801029ae:	eb dd                	jmp    8010298d <log_write+0x82>

801029b0 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801029b0:	55                   	push   %ebp
801029b1:	89 e5                	mov    %esp,%ebp
801029b3:	53                   	push   %ebx
801029b4:	83 ec 08             	sub    $0x8,%esp

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801029b7:	68 8a 00 00 00       	push   $0x8a
801029bc:	68 8c 94 10 80       	push   $0x8010948c
801029c1:	68 00 70 00 80       	push   $0x80007000
801029c6:	e8 d6 13 00 00       	call   80103da1 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
801029cb:	83 c4 10             	add    $0x10,%esp
801029ce:	bb e0 37 11 80       	mov    $0x801137e0,%ebx
801029d3:	eb 06                	jmp    801029db <startothers+0x2b>
801029d5:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
801029db:	69 05 60 3d 11 80 b0 	imul   $0xb0,0x80113d60,%eax
801029e2:	00 00 00 
801029e5:	05 e0 37 11 80       	add    $0x801137e0,%eax
801029ea:	39 d8                	cmp    %ebx,%eax
801029ec:	76 4c                	jbe    80102a3a <startothers+0x8a>
    if(c == mycpu())  // We've started already.
801029ee:	e8 d7 07 00 00       	call   801031ca <mycpu>
801029f3:	39 d8                	cmp    %ebx,%eax
801029f5:	74 de                	je     801029d5 <startothers+0x25>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801029f7:	e8 f3 f6 ff ff       	call   801020ef <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
801029fc:	05 00 10 00 00       	add    $0x1000,%eax
80102a01:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    *(void**)(code-8) = mpenter;
80102a06:	c7 05 f8 6f 00 80 7e 	movl   $0x80102a7e,0x80006ff8
80102a0d:	2a 10 80 
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80102a10:	c7 05 f4 6f 00 80 00 	movl   $0x108000,0x80006ff4
80102a17:	80 10 00 

    lapicstartap(c->apicid, V2P(code));
80102a1a:	83 ec 08             	sub    $0x8,%esp
80102a1d:	68 00 70 00 00       	push   $0x7000
80102a22:	0f b6 03             	movzbl (%ebx),%eax
80102a25:	50                   	push   %eax
80102a26:	e8 c6 f9 ff ff       	call   801023f1 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80102a2b:	83 c4 10             	add    $0x10,%esp
80102a2e:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
80102a34:	85 c0                	test   %eax,%eax
80102a36:	74 f6                	je     80102a2e <startothers+0x7e>
80102a38:	eb 9b                	jmp    801029d5 <startothers+0x25>
      ;
  }
}
80102a3a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102a3d:	c9                   	leave  
80102a3e:	c3                   	ret    

80102a3f <mpmain>:
{
80102a3f:	55                   	push   %ebp
80102a40:	89 e5                	mov    %esp,%ebp
80102a42:	53                   	push   %ebx
80102a43:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80102a46:	e8 db 07 00 00       	call   80103226 <cpuid>
80102a4b:	89 c3                	mov    %eax,%ebx
80102a4d:	e8 d4 07 00 00       	call   80103226 <cpuid>
80102a52:	83 ec 04             	sub    $0x4,%esp
80102a55:	53                   	push   %ebx
80102a56:	50                   	push   %eax
80102a57:	68 c4 69 10 80       	push   $0x801069c4
80102a5c:	e8 aa db ff ff       	call   8010060b <cprintf>
  idtinit();       // load idt register
80102a61:	e8 03 24 00 00       	call   80104e69 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80102a66:	e8 5f 07 00 00       	call   801031ca <mycpu>
80102a6b:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80102a6d:	b8 01 00 00 00       	mov    $0x1,%eax
80102a72:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
80102a79:	e8 48 0a 00 00       	call   801034c6 <scheduler>

80102a7e <mpenter>:
{
80102a7e:	55                   	push   %ebp
80102a7f:	89 e5                	mov    %esp,%ebp
80102a81:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80102a84:	e8 f1 33 00 00       	call   80105e7a <switchkvm>
  seginit();
80102a89:	e8 a0 32 00 00       	call   80105d2e <seginit>
  lapicinit();
80102a8e:	e8 15 f8 ff ff       	call   801022a8 <lapicinit>
  mpmain();
80102a93:	e8 a7 ff ff ff       	call   80102a3f <mpmain>

80102a98 <main>:
{
80102a98:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80102a9c:	83 e4 f0             	and    $0xfffffff0,%esp
80102a9f:	ff 71 fc             	pushl  -0x4(%ecx)
80102aa2:	55                   	push   %ebp
80102aa3:	89 e5                	mov    %esp,%ebp
80102aa5:	51                   	push   %ecx
80102aa6:	83 ec 0c             	sub    $0xc,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80102aa9:	68 00 00 40 80       	push   $0x80400000
80102aae:	68 88 45 11 80       	push   $0x80114588
80102ab3:	e8 e5 f5 ff ff       	call   8010209d <kinit1>
  kvmalloc();      // kernel page table
80102ab8:	e8 4a 38 00 00       	call   80106307 <kvmalloc>
  mpinit();        // detect other processors
80102abd:	e8 c9 01 00 00       	call   80102c8b <mpinit>
  lapicinit();     // interrupt controller
80102ac2:	e8 e1 f7 ff ff       	call   801022a8 <lapicinit>
  seginit();       // segment descriptors
80102ac7:	e8 62 32 00 00       	call   80105d2e <seginit>
  picinit();       // disable pic
80102acc:	e8 82 02 00 00       	call   80102d53 <picinit>
  ioapicinit();    // another interrupt controller
80102ad1:	e8 58 f4 ff ff       	call   80101f2e <ioapicinit>
  consoleinit();   // console hardware
80102ad6:	e8 f6 dd ff ff       	call   801008d1 <consoleinit>
  uartinit();      // serial port
80102adb:	e8 3f 26 00 00       	call   8010511f <uartinit>
  pinit();         // process table
80102ae0:	e8 cb 06 00 00       	call   801031b0 <pinit>
  tvinit();        // trap vectors
80102ae5:	e8 e6 22 00 00       	call   80104dd0 <tvinit>
  binit();         // buffer cache
80102aea:	e8 05 d6 ff ff       	call   801000f4 <binit>
  fileinit();      // file table
80102aef:	e8 53 e1 ff ff       	call   80100c47 <fileinit>
  ideinit();       // disk 
80102af4:	e8 3b f2 ff ff       	call   80101d34 <ideinit>
  startothers();   // start other processors
80102af9:	e8 b2 fe ff ff       	call   801029b0 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80102afe:	83 c4 08             	add    $0x8,%esp
80102b01:	68 00 00 00 8e       	push   $0x8e000000
80102b06:	68 00 00 40 80       	push   $0x80400000
80102b0b:	e8 bf f5 ff ff       	call   801020cf <kinit2>
  userinit();      // first user process
80102b10:	e8 50 07 00 00       	call   80103265 <userinit>
  mpmain();        // finish this processor's setup
80102b15:	e8 25 ff ff ff       	call   80102a3f <mpmain>

80102b1a <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80102b1a:	55                   	push   %ebp
80102b1b:	89 e5                	mov    %esp,%ebp
80102b1d:	56                   	push   %esi
80102b1e:	53                   	push   %ebx
  int i, sum;

  sum = 0;
80102b1f:	bb 00 00 00 00       	mov    $0x0,%ebx
  for(i=0; i<len; i++)
80102b24:	b9 00 00 00 00       	mov    $0x0,%ecx
80102b29:	eb 09                	jmp    80102b34 <sum+0x1a>
    sum += addr[i];
80102b2b:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
80102b2f:	01 f3                	add    %esi,%ebx
  for(i=0; i<len; i++)
80102b31:	83 c1 01             	add    $0x1,%ecx
80102b34:	39 d1                	cmp    %edx,%ecx
80102b36:	7c f3                	jl     80102b2b <sum+0x11>
  return sum;
}
80102b38:	89 d8                	mov    %ebx,%eax
80102b3a:	5b                   	pop    %ebx
80102b3b:	5e                   	pop    %esi
80102b3c:	5d                   	pop    %ebp
80102b3d:	c3                   	ret    

80102b3e <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80102b3e:	55                   	push   %ebp
80102b3f:	89 e5                	mov    %esp,%ebp
80102b41:	56                   	push   %esi
80102b42:	53                   	push   %ebx
  uchar *e, *p, *addr;

  addr = P2V(a);
80102b43:	8d b0 00 00 00 80    	lea    -0x80000000(%eax),%esi
80102b49:	89 f3                	mov    %esi,%ebx
  e = addr+len;
80102b4b:	01 d6                	add    %edx,%esi
  for(p = addr; p < e; p += sizeof(struct mp))
80102b4d:	eb 03                	jmp    80102b52 <mpsearch1+0x14>
80102b4f:	83 c3 10             	add    $0x10,%ebx
80102b52:	39 f3                	cmp    %esi,%ebx
80102b54:	73 29                	jae    80102b7f <mpsearch1+0x41>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80102b56:	83 ec 04             	sub    $0x4,%esp
80102b59:	6a 04                	push   $0x4
80102b5b:	68 d8 69 10 80       	push   $0x801069d8
80102b60:	53                   	push   %ebx
80102b61:	e8 06 12 00 00       	call   80103d6c <memcmp>
80102b66:	83 c4 10             	add    $0x10,%esp
80102b69:	85 c0                	test   %eax,%eax
80102b6b:	75 e2                	jne    80102b4f <mpsearch1+0x11>
80102b6d:	ba 10 00 00 00       	mov    $0x10,%edx
80102b72:	89 d8                	mov    %ebx,%eax
80102b74:	e8 a1 ff ff ff       	call   80102b1a <sum>
80102b79:	84 c0                	test   %al,%al
80102b7b:	75 d2                	jne    80102b4f <mpsearch1+0x11>
80102b7d:	eb 05                	jmp    80102b84 <mpsearch1+0x46>
      return (struct mp*)p;
  return 0;
80102b7f:	bb 00 00 00 00       	mov    $0x0,%ebx
}
80102b84:	89 d8                	mov    %ebx,%eax
80102b86:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102b89:	5b                   	pop    %ebx
80102b8a:	5e                   	pop    %esi
80102b8b:	5d                   	pop    %ebp
80102b8c:	c3                   	ret    

80102b8d <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80102b8d:	55                   	push   %ebp
80102b8e:	89 e5                	mov    %esp,%ebp
80102b90:	83 ec 08             	sub    $0x8,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80102b93:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80102b9a:	c1 e0 08             	shl    $0x8,%eax
80102b9d:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
80102ba4:	09 d0                	or     %edx,%eax
80102ba6:	c1 e0 04             	shl    $0x4,%eax
80102ba9:	85 c0                	test   %eax,%eax
80102bab:	74 1f                	je     80102bcc <mpsearch+0x3f>
    if((mp = mpsearch1(p, 1024)))
80102bad:	ba 00 04 00 00       	mov    $0x400,%edx
80102bb2:	e8 87 ff ff ff       	call   80102b3e <mpsearch1>
80102bb7:	85 c0                	test   %eax,%eax
80102bb9:	75 0f                	jne    80102bca <mpsearch+0x3d>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1(p-1024, 1024)))
      return mp;
  }
  return mpsearch1(0xF0000, 0x10000);
80102bbb:	ba 00 00 01 00       	mov    $0x10000,%edx
80102bc0:	b8 00 00 0f 00       	mov    $0xf0000,%eax
80102bc5:	e8 74 ff ff ff       	call   80102b3e <mpsearch1>
}
80102bca:	c9                   	leave  
80102bcb:	c3                   	ret    
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80102bcc:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
80102bd3:	c1 e0 08             	shl    $0x8,%eax
80102bd6:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
80102bdd:	09 d0                	or     %edx,%eax
80102bdf:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
80102be2:	2d 00 04 00 00       	sub    $0x400,%eax
80102be7:	ba 00 04 00 00       	mov    $0x400,%edx
80102bec:	e8 4d ff ff ff       	call   80102b3e <mpsearch1>
80102bf1:	85 c0                	test   %eax,%eax
80102bf3:	75 d5                	jne    80102bca <mpsearch+0x3d>
80102bf5:	eb c4                	jmp    80102bbb <mpsearch+0x2e>

80102bf7 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80102bf7:	55                   	push   %ebp
80102bf8:	89 e5                	mov    %esp,%ebp
80102bfa:	57                   	push   %edi
80102bfb:	56                   	push   %esi
80102bfc:	53                   	push   %ebx
80102bfd:	83 ec 1c             	sub    $0x1c,%esp
80102c00:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80102c03:	e8 85 ff ff ff       	call   80102b8d <mpsearch>
80102c08:	85 c0                	test   %eax,%eax
80102c0a:	74 5c                	je     80102c68 <mpconfig+0x71>
80102c0c:	89 c7                	mov    %eax,%edi
80102c0e:	8b 58 04             	mov    0x4(%eax),%ebx
80102c11:	85 db                	test   %ebx,%ebx
80102c13:	74 5a                	je     80102c6f <mpconfig+0x78>
    return 0;
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80102c15:	8d b3 00 00 00 80    	lea    -0x80000000(%ebx),%esi
  if(memcmp(conf, "PCMP", 4) != 0)
80102c1b:	83 ec 04             	sub    $0x4,%esp
80102c1e:	6a 04                	push   $0x4
80102c20:	68 dd 69 10 80       	push   $0x801069dd
80102c25:	56                   	push   %esi
80102c26:	e8 41 11 00 00       	call   80103d6c <memcmp>
80102c2b:	83 c4 10             	add    $0x10,%esp
80102c2e:	85 c0                	test   %eax,%eax
80102c30:	75 44                	jne    80102c76 <mpconfig+0x7f>
    return 0;
  if(conf->version != 1 && conf->version != 4)
80102c32:	0f b6 83 06 00 00 80 	movzbl -0x7ffffffa(%ebx),%eax
80102c39:	3c 01                	cmp    $0x1,%al
80102c3b:	0f 95 c2             	setne  %dl
80102c3e:	3c 04                	cmp    $0x4,%al
80102c40:	0f 95 c0             	setne  %al
80102c43:	84 c2                	test   %al,%dl
80102c45:	75 36                	jne    80102c7d <mpconfig+0x86>
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
80102c47:	0f b7 93 04 00 00 80 	movzwl -0x7ffffffc(%ebx),%edx
80102c4e:	89 f0                	mov    %esi,%eax
80102c50:	e8 c5 fe ff ff       	call   80102b1a <sum>
80102c55:	84 c0                	test   %al,%al
80102c57:	75 2b                	jne    80102c84 <mpconfig+0x8d>
    return 0;
  *pmp = mp;
80102c59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102c5c:	89 38                	mov    %edi,(%eax)
  return conf;
}
80102c5e:	89 f0                	mov    %esi,%eax
80102c60:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102c63:	5b                   	pop    %ebx
80102c64:	5e                   	pop    %esi
80102c65:	5f                   	pop    %edi
80102c66:	5d                   	pop    %ebp
80102c67:	c3                   	ret    
    return 0;
80102c68:	be 00 00 00 00       	mov    $0x0,%esi
80102c6d:	eb ef                	jmp    80102c5e <mpconfig+0x67>
80102c6f:	be 00 00 00 00       	mov    $0x0,%esi
80102c74:	eb e8                	jmp    80102c5e <mpconfig+0x67>
    return 0;
80102c76:	be 00 00 00 00       	mov    $0x0,%esi
80102c7b:	eb e1                	jmp    80102c5e <mpconfig+0x67>
    return 0;
80102c7d:	be 00 00 00 00       	mov    $0x0,%esi
80102c82:	eb da                	jmp    80102c5e <mpconfig+0x67>
    return 0;
80102c84:	be 00 00 00 00       	mov    $0x0,%esi
80102c89:	eb d3                	jmp    80102c5e <mpconfig+0x67>

80102c8b <mpinit>:

void
mpinit(void)
{
80102c8b:	55                   	push   %ebp
80102c8c:	89 e5                	mov    %esp,%ebp
80102c8e:	57                   	push   %edi
80102c8f:	56                   	push   %esi
80102c90:	53                   	push   %ebx
80102c91:	83 ec 1c             	sub    $0x1c,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80102c94:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80102c97:	e8 5b ff ff ff       	call   80102bf7 <mpconfig>
80102c9c:	85 c0                	test   %eax,%eax
80102c9e:	74 19                	je     80102cb9 <mpinit+0x2e>
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
80102ca0:	8b 50 24             	mov    0x24(%eax),%edx
80102ca3:	89 15 dc 36 11 80    	mov    %edx,0x801136dc
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102ca9:	8d 50 2c             	lea    0x2c(%eax),%edx
80102cac:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
80102cb0:	01 c1                	add    %eax,%ecx
  ismp = 1;
80102cb2:	bb 01 00 00 00       	mov    $0x1,%ebx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102cb7:	eb 34                	jmp    80102ced <mpinit+0x62>
    panic("Expect to run on an SMP");
80102cb9:	83 ec 0c             	sub    $0xc,%esp
80102cbc:	68 e2 69 10 80       	push   $0x801069e2
80102cc1:	e8 82 d6 ff ff       	call   80100348 <panic>
    switch(*p){
    case MPPROC:
      proc = (struct mpproc*)p;
      if(ncpu < NCPU) {
80102cc6:	8b 35 60 3d 11 80    	mov    0x80113d60,%esi
80102ccc:	83 fe 07             	cmp    $0x7,%esi
80102ccf:	7f 19                	jg     80102cea <mpinit+0x5f>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80102cd1:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102cd5:	69 fe b0 00 00 00    	imul   $0xb0,%esi,%edi
80102cdb:	88 87 e0 37 11 80    	mov    %al,-0x7feec820(%edi)
        ncpu++;
80102ce1:	83 c6 01             	add    $0x1,%esi
80102ce4:	89 35 60 3d 11 80    	mov    %esi,0x80113d60
      }
      p += sizeof(struct mpproc);
80102cea:	83 c2 14             	add    $0x14,%edx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102ced:	39 ca                	cmp    %ecx,%edx
80102cef:	73 2b                	jae    80102d1c <mpinit+0x91>
    switch(*p){
80102cf1:	0f b6 02             	movzbl (%edx),%eax
80102cf4:	3c 04                	cmp    $0x4,%al
80102cf6:	77 1d                	ja     80102d15 <mpinit+0x8a>
80102cf8:	0f b6 c0             	movzbl %al,%eax
80102cfb:	ff 24 85 1c 6a 10 80 	jmp    *-0x7fef95e4(,%eax,4)
      continue;
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
      ioapicid = ioapic->apicno;
80102d02:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102d06:	a2 c0 37 11 80       	mov    %al,0x801137c0
      p += sizeof(struct mpioapic);
80102d0b:	83 c2 08             	add    $0x8,%edx
      continue;
80102d0e:	eb dd                	jmp    80102ced <mpinit+0x62>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80102d10:	83 c2 08             	add    $0x8,%edx
      continue;
80102d13:	eb d8                	jmp    80102ced <mpinit+0x62>
    default:
      ismp = 0;
80102d15:	bb 00 00 00 00       	mov    $0x0,%ebx
80102d1a:	eb d1                	jmp    80102ced <mpinit+0x62>
      break;
    }
  }
  if(!ismp)
80102d1c:	85 db                	test   %ebx,%ebx
80102d1e:	74 26                	je     80102d46 <mpinit+0xbb>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
80102d20:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d23:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
80102d27:	74 15                	je     80102d3e <mpinit+0xb3>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d29:	b8 70 00 00 00       	mov    $0x70,%eax
80102d2e:	ba 22 00 00 00       	mov    $0x22,%edx
80102d33:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d34:	ba 23 00 00 00       	mov    $0x23,%edx
80102d39:	ec                   	in     (%dx),%al
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80102d3a:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d3d:	ee                   	out    %al,(%dx)
  }
}
80102d3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102d41:	5b                   	pop    %ebx
80102d42:	5e                   	pop    %esi
80102d43:	5f                   	pop    %edi
80102d44:	5d                   	pop    %ebp
80102d45:	c3                   	ret    
    panic("Didn't find a suitable machine");
80102d46:	83 ec 0c             	sub    $0xc,%esp
80102d49:	68 fc 69 10 80       	push   $0x801069fc
80102d4e:	e8 f5 d5 ff ff       	call   80100348 <panic>

80102d53 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80102d53:	55                   	push   %ebp
80102d54:	89 e5                	mov    %esp,%ebp
80102d56:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d5b:	ba 21 00 00 00       	mov    $0x21,%edx
80102d60:	ee                   	out    %al,(%dx)
80102d61:	ba a1 00 00 00       	mov    $0xa1,%edx
80102d66:	ee                   	out    %al,(%dx)
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);
}
80102d67:	5d                   	pop    %ebp
80102d68:	c3                   	ret    

80102d69 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80102d69:	55                   	push   %ebp
80102d6a:	89 e5                	mov    %esp,%ebp
80102d6c:	57                   	push   %edi
80102d6d:	56                   	push   %esi
80102d6e:	53                   	push   %ebx
80102d6f:	83 ec 0c             	sub    $0xc,%esp
80102d72:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102d75:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
80102d78:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80102d7e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80102d84:	e8 d8 de ff ff       	call   80100c61 <filealloc>
80102d89:	89 03                	mov    %eax,(%ebx)
80102d8b:	85 c0                	test   %eax,%eax
80102d8d:	74 16                	je     80102da5 <pipealloc+0x3c>
80102d8f:	e8 cd de ff ff       	call   80100c61 <filealloc>
80102d94:	89 06                	mov    %eax,(%esi)
80102d96:	85 c0                	test   %eax,%eax
80102d98:	74 0b                	je     80102da5 <pipealloc+0x3c>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80102d9a:	e8 50 f3 ff ff       	call   801020ef <kalloc>
80102d9f:	89 c7                	mov    %eax,%edi
80102da1:	85 c0                	test   %eax,%eax
80102da3:	75 35                	jne    80102dda <pipealloc+0x71>

//PAGEBREAK: 20
 bad:
  if(p)
    kfree((char*)p);
  if(*f0)
80102da5:	8b 03                	mov    (%ebx),%eax
80102da7:	85 c0                	test   %eax,%eax
80102da9:	74 0c                	je     80102db7 <pipealloc+0x4e>
    fileclose(*f0);
80102dab:	83 ec 0c             	sub    $0xc,%esp
80102dae:	50                   	push   %eax
80102daf:	e8 53 df ff ff       	call   80100d07 <fileclose>
80102db4:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80102db7:	8b 06                	mov    (%esi),%eax
80102db9:	85 c0                	test   %eax,%eax
80102dbb:	0f 84 8b 00 00 00    	je     80102e4c <pipealloc+0xe3>
    fileclose(*f1);
80102dc1:	83 ec 0c             	sub    $0xc,%esp
80102dc4:	50                   	push   %eax
80102dc5:	e8 3d df ff ff       	call   80100d07 <fileclose>
80102dca:	83 c4 10             	add    $0x10,%esp
  return -1;
80102dcd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102dd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102dd5:	5b                   	pop    %ebx
80102dd6:	5e                   	pop    %esi
80102dd7:	5f                   	pop    %edi
80102dd8:	5d                   	pop    %ebp
80102dd9:	c3                   	ret    
  p->readopen = 1;
80102dda:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80102de1:	00 00 00 
  p->writeopen = 1;
80102de4:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80102deb:	00 00 00 
  p->nwrite = 0;
80102dee:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80102df5:	00 00 00 
  p->nread = 0;
80102df8:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80102dff:	00 00 00 
  initlock(&p->lock, "pipe");
80102e02:	83 ec 08             	sub    $0x8,%esp
80102e05:	68 30 6a 10 80       	push   $0x80106a30
80102e0a:	50                   	push   %eax
80102e0b:	e8 2e 0d 00 00       	call   80103b3e <initlock>
  (*f0)->type = FD_PIPE;
80102e10:	8b 03                	mov    (%ebx),%eax
80102e12:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80102e18:	8b 03                	mov    (%ebx),%eax
80102e1a:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80102e1e:	8b 03                	mov    (%ebx),%eax
80102e20:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80102e24:	8b 03                	mov    (%ebx),%eax
80102e26:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
80102e29:	8b 06                	mov    (%esi),%eax
80102e2b:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80102e31:	8b 06                	mov    (%esi),%eax
80102e33:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80102e37:	8b 06                	mov    (%esi),%eax
80102e39:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80102e3d:	8b 06                	mov    (%esi),%eax
80102e3f:	89 78 0c             	mov    %edi,0xc(%eax)
  return 0;
80102e42:	83 c4 10             	add    $0x10,%esp
80102e45:	b8 00 00 00 00       	mov    $0x0,%eax
80102e4a:	eb 86                	jmp    80102dd2 <pipealloc+0x69>
  return -1;
80102e4c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102e51:	e9 7c ff ff ff       	jmp    80102dd2 <pipealloc+0x69>

80102e56 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80102e56:	55                   	push   %ebp
80102e57:	89 e5                	mov    %esp,%ebp
80102e59:	53                   	push   %ebx
80102e5a:	83 ec 10             	sub    $0x10,%esp
80102e5d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&p->lock);
80102e60:	53                   	push   %ebx
80102e61:	e8 14 0e 00 00       	call   80103c7a <acquire>
  if(writable){
80102e66:	83 c4 10             	add    $0x10,%esp
80102e69:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102e6d:	74 3f                	je     80102eae <pipeclose+0x58>
    p->writeopen = 0;
80102e6f:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
80102e76:	00 00 00 
    wakeup(&p->nread);
80102e79:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102e7f:	83 ec 0c             	sub    $0xc,%esp
80102e82:	50                   	push   %eax
80102e83:	e8 eb 09 00 00       	call   80103873 <wakeup>
80102e88:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
80102e8b:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80102e92:	75 09                	jne    80102e9d <pipeclose+0x47>
80102e94:	83 bb 40 02 00 00 00 	cmpl   $0x0,0x240(%ebx)
80102e9b:	74 2f                	je     80102ecc <pipeclose+0x76>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
80102e9d:	83 ec 0c             	sub    $0xc,%esp
80102ea0:	53                   	push   %ebx
80102ea1:	e8 39 0e 00 00       	call   80103cdf <release>
80102ea6:	83 c4 10             	add    $0x10,%esp
}
80102ea9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102eac:	c9                   	leave  
80102ead:	c3                   	ret    
    p->readopen = 0;
80102eae:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
80102eb5:	00 00 00 
    wakeup(&p->nwrite);
80102eb8:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102ebe:	83 ec 0c             	sub    $0xc,%esp
80102ec1:	50                   	push   %eax
80102ec2:	e8 ac 09 00 00       	call   80103873 <wakeup>
80102ec7:	83 c4 10             	add    $0x10,%esp
80102eca:	eb bf                	jmp    80102e8b <pipeclose+0x35>
    release(&p->lock);
80102ecc:	83 ec 0c             	sub    $0xc,%esp
80102ecf:	53                   	push   %ebx
80102ed0:	e8 0a 0e 00 00       	call   80103cdf <release>
    kfree((char*)p);
80102ed5:	89 1c 24             	mov    %ebx,(%esp)
80102ed8:	e8 fb f0 ff ff       	call   80101fd8 <kfree>
80102edd:	83 c4 10             	add    $0x10,%esp
80102ee0:	eb c7                	jmp    80102ea9 <pipeclose+0x53>

80102ee2 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80102ee2:	55                   	push   %ebp
80102ee3:	89 e5                	mov    %esp,%ebp
80102ee5:	57                   	push   %edi
80102ee6:	56                   	push   %esi
80102ee7:	53                   	push   %ebx
80102ee8:	83 ec 18             	sub    $0x18,%esp
80102eeb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
80102eee:	89 de                	mov    %ebx,%esi
80102ef0:	53                   	push   %ebx
80102ef1:	e8 84 0d 00 00       	call   80103c7a <acquire>
  for(i = 0; i < n; i++){
80102ef6:	83 c4 10             	add    $0x10,%esp
80102ef9:	bf 00 00 00 00       	mov    $0x0,%edi
80102efe:	3b 7d 10             	cmp    0x10(%ebp),%edi
80102f01:	0f 8d 88 00 00 00    	jge    80102f8f <pipewrite+0xad>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80102f07:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
80102f0d:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80102f13:	05 00 02 00 00       	add    $0x200,%eax
80102f18:	39 c2                	cmp    %eax,%edx
80102f1a:	75 51                	jne    80102f6d <pipewrite+0x8b>
      if(p->readopen == 0 || myproc()->killed){
80102f1c:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80102f23:	74 2f                	je     80102f54 <pipewrite+0x72>
80102f25:	e8 17 03 00 00       	call   80103241 <myproc>
80102f2a:	83 78 28 00          	cmpl   $0x0,0x28(%eax)
80102f2e:	75 24                	jne    80102f54 <pipewrite+0x72>
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
80102f30:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102f36:	83 ec 0c             	sub    $0xc,%esp
80102f39:	50                   	push   %eax
80102f3a:	e8 34 09 00 00       	call   80103873 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80102f3f:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102f45:	83 c4 08             	add    $0x8,%esp
80102f48:	56                   	push   %esi
80102f49:	50                   	push   %eax
80102f4a:	e8 c0 07 00 00       	call   8010370f <sleep>
80102f4f:	83 c4 10             	add    $0x10,%esp
80102f52:	eb b3                	jmp    80102f07 <pipewrite+0x25>
        release(&p->lock);
80102f54:	83 ec 0c             	sub    $0xc,%esp
80102f57:	53                   	push   %ebx
80102f58:	e8 82 0d 00 00       	call   80103cdf <release>
        return -1;
80102f5d:	83 c4 10             	add    $0x10,%esp
80102f60:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  release(&p->lock);
  return n;
}
80102f65:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102f68:	5b                   	pop    %ebx
80102f69:	5e                   	pop    %esi
80102f6a:	5f                   	pop    %edi
80102f6b:	5d                   	pop    %ebp
80102f6c:	c3                   	ret    
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80102f6d:	8d 42 01             	lea    0x1(%edx),%eax
80102f70:	89 83 38 02 00 00    	mov    %eax,0x238(%ebx)
80102f76:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80102f7c:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f7f:	0f b6 04 38          	movzbl (%eax,%edi,1),%eax
80102f83:	88 44 13 34          	mov    %al,0x34(%ebx,%edx,1)
  for(i = 0; i < n; i++){
80102f87:	83 c7 01             	add    $0x1,%edi
80102f8a:	e9 6f ff ff ff       	jmp    80102efe <pipewrite+0x1c>
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80102f8f:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102f95:	83 ec 0c             	sub    $0xc,%esp
80102f98:	50                   	push   %eax
80102f99:	e8 d5 08 00 00       	call   80103873 <wakeup>
  release(&p->lock);
80102f9e:	89 1c 24             	mov    %ebx,(%esp)
80102fa1:	e8 39 0d 00 00       	call   80103cdf <release>
  return n;
80102fa6:	83 c4 10             	add    $0x10,%esp
80102fa9:	8b 45 10             	mov    0x10(%ebp),%eax
80102fac:	eb b7                	jmp    80102f65 <pipewrite+0x83>

80102fae <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80102fae:	55                   	push   %ebp
80102faf:	89 e5                	mov    %esp,%ebp
80102fb1:	57                   	push   %edi
80102fb2:	56                   	push   %esi
80102fb3:	53                   	push   %ebx
80102fb4:	83 ec 18             	sub    $0x18,%esp
80102fb7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
80102fba:	89 df                	mov    %ebx,%edi
80102fbc:	53                   	push   %ebx
80102fbd:	e8 b8 0c 00 00       	call   80103c7a <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80102fc2:	83 c4 10             	add    $0x10,%esp
80102fc5:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
80102fcb:	39 83 34 02 00 00    	cmp    %eax,0x234(%ebx)
80102fd1:	75 3d                	jne    80103010 <piperead+0x62>
80102fd3:	8b b3 40 02 00 00    	mov    0x240(%ebx),%esi
80102fd9:	85 f6                	test   %esi,%esi
80102fdb:	74 38                	je     80103015 <piperead+0x67>
    if(myproc()->killed){
80102fdd:	e8 5f 02 00 00       	call   80103241 <myproc>
80102fe2:	83 78 28 00          	cmpl   $0x0,0x28(%eax)
80102fe6:	75 15                	jne    80102ffd <piperead+0x4f>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80102fe8:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102fee:	83 ec 08             	sub    $0x8,%esp
80102ff1:	57                   	push   %edi
80102ff2:	50                   	push   %eax
80102ff3:	e8 17 07 00 00       	call   8010370f <sleep>
80102ff8:	83 c4 10             	add    $0x10,%esp
80102ffb:	eb c8                	jmp    80102fc5 <piperead+0x17>
      release(&p->lock);
80102ffd:	83 ec 0c             	sub    $0xc,%esp
80103000:	53                   	push   %ebx
80103001:	e8 d9 0c 00 00       	call   80103cdf <release>
      return -1;
80103006:	83 c4 10             	add    $0x10,%esp
80103009:	be ff ff ff ff       	mov    $0xffffffff,%esi
8010300e:	eb 50                	jmp    80103060 <piperead+0xb2>
80103010:	be 00 00 00 00       	mov    $0x0,%esi
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103015:	3b 75 10             	cmp    0x10(%ebp),%esi
80103018:	7d 2c                	jge    80103046 <piperead+0x98>
    if(p->nread == p->nwrite)
8010301a:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80103020:	3b 83 38 02 00 00    	cmp    0x238(%ebx),%eax
80103026:	74 1e                	je     80103046 <piperead+0x98>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103028:	8d 50 01             	lea    0x1(%eax),%edx
8010302b:	89 93 34 02 00 00    	mov    %edx,0x234(%ebx)
80103031:	25 ff 01 00 00       	and    $0x1ff,%eax
80103036:	0f b6 44 03 34       	movzbl 0x34(%ebx,%eax,1),%eax
8010303b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010303e:	88 04 31             	mov    %al,(%ecx,%esi,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103041:	83 c6 01             	add    $0x1,%esi
80103044:	eb cf                	jmp    80103015 <piperead+0x67>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103046:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
8010304c:	83 ec 0c             	sub    $0xc,%esp
8010304f:	50                   	push   %eax
80103050:	e8 1e 08 00 00       	call   80103873 <wakeup>
  release(&p->lock);
80103055:	89 1c 24             	mov    %ebx,(%esp)
80103058:	e8 82 0c 00 00       	call   80103cdf <release>
  return i;
8010305d:	83 c4 10             	add    $0x10,%esp
}
80103060:	89 f0                	mov    %esi,%eax
80103062:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103065:	5b                   	pop    %ebx
80103066:	5e                   	pop    %esi
80103067:	5f                   	pop    %edi
80103068:	5d                   	pop    %ebp
80103069:	c3                   	ret    

8010306a <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
8010306a:	55                   	push   %ebp
8010306b:	89 e5                	mov    %esp,%ebp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010306d:	ba 14 96 10 80       	mov    $0x80109614,%edx
80103072:	eb 03                	jmp    80103077 <wakeup1+0xd>
80103074:	83 ea 80             	sub    $0xffffff80,%edx
80103077:	81 fa 14 b6 10 80    	cmp    $0x8010b614,%edx
8010307d:	73 14                	jae    80103093 <wakeup1+0x29>
    if(p->state == SLEEPING && p->chan == chan)
8010307f:	83 7a 10 02          	cmpl   $0x2,0x10(%edx)
80103083:	75 ef                	jne    80103074 <wakeup1+0xa>
80103085:	39 42 24             	cmp    %eax,0x24(%edx)
80103088:	75 ea                	jne    80103074 <wakeup1+0xa>
      p->state = RUNNABLE;
8010308a:	c7 42 10 03 00 00 00 	movl   $0x3,0x10(%edx)
80103091:	eb e1                	jmp    80103074 <wakeup1+0xa>
}
80103093:	5d                   	pop    %ebp
80103094:	c3                   	ret    

80103095 <allocproc>:
{
80103095:	55                   	push   %ebp
80103096:	89 e5                	mov    %esp,%ebp
80103098:	53                   	push   %ebx
80103099:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);
8010309c:	68 e0 95 10 80       	push   $0x801095e0
801030a1:	e8 d4 0b 00 00       	call   80103c7a <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801030a6:	83 c4 10             	add    $0x10,%esp
801030a9:	bb 14 96 10 80       	mov    $0x80109614,%ebx
801030ae:	81 fb 14 b6 10 80    	cmp    $0x8010b614,%ebx
801030b4:	73 0b                	jae    801030c1 <allocproc+0x2c>
    if(p->state == UNUSED) {
801030b6:	83 7b 10 00          	cmpl   $0x0,0x10(%ebx)
801030ba:	74 0c                	je     801030c8 <allocproc+0x33>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801030bc:	83 eb 80             	sub    $0xffffff80,%ebx
801030bf:	eb ed                	jmp    801030ae <allocproc+0x19>
  int found = 0;
801030c1:	b8 00 00 00 00       	mov    $0x0,%eax
801030c6:	eb 05                	jmp    801030cd <allocproc+0x38>
      found = 1;
801030c8:	b8 01 00 00 00       	mov    $0x1,%eax
  if (!found) {
801030cd:	85 c0                	test   %eax,%eax
801030cf:	74 77                	je     80103148 <allocproc+0xb3>
  p->state = EMBRYO;
801030d1:	c7 43 10 01 00 00 00 	movl   $0x1,0x10(%ebx)
  p->pid = nextpid++;
801030d8:	a1 04 90 10 80       	mov    0x80109004,%eax
801030dd:	8d 50 01             	lea    0x1(%eax),%edx
801030e0:	89 15 04 90 10 80    	mov    %edx,0x80109004
801030e6:	89 43 14             	mov    %eax,0x14(%ebx)
  release(&ptable.lock);
801030e9:	83 ec 0c             	sub    $0xc,%esp
801030ec:	68 e0 95 10 80       	push   $0x801095e0
801030f1:	e8 e9 0b 00 00       	call   80103cdf <release>
  if((p->kstack = kalloc()) == 0){
801030f6:	e8 f4 ef ff ff       	call   801020ef <kalloc>
801030fb:	89 43 0c             	mov    %eax,0xc(%ebx)
801030fe:	83 c4 10             	add    $0x10,%esp
80103101:	85 c0                	test   %eax,%eax
80103103:	74 5a                	je     8010315f <allocproc+0xca>
  sp -= sizeof *p->tf;
80103105:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  p->tf = (struct trapframe*)sp;
8010310b:	89 53 1c             	mov    %edx,0x1c(%ebx)
  *(uint*)sp = (uint)trapret;
8010310e:	c7 80 b0 0f 00 00 c5 	movl   $0x80104dc5,0xfb0(%eax)
80103115:	4d 10 80 
  sp -= sizeof *p->context;
80103118:	05 9c 0f 00 00       	add    $0xf9c,%eax
  p->context = (struct context*)sp;
8010311d:	89 43 20             	mov    %eax,0x20(%ebx)
  memset(p->context, 0, sizeof *p->context);
80103120:	83 ec 04             	sub    $0x4,%esp
80103123:	6a 14                	push   $0x14
80103125:	6a 00                	push   $0x0
80103127:	50                   	push   %eax
80103128:	e8 f9 0b 00 00       	call   80103d26 <memset>
  p->context->eip = (uint)forkret;
8010312d:	8b 43 20             	mov    0x20(%ebx),%eax
80103130:	c7 40 10 6d 31 10 80 	movl   $0x8010316d,0x10(%eax)
  p->start_ticks = ticks;
80103137:	a1 80 45 11 80       	mov    0x80114580,%eax
8010313c:	89 03                	mov    %eax,(%ebx)
  return p;
8010313e:	83 c4 10             	add    $0x10,%esp
}
80103141:	89 d8                	mov    %ebx,%eax
80103143:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103146:	c9                   	leave  
80103147:	c3                   	ret    
    release(&ptable.lock);
80103148:	83 ec 0c             	sub    $0xc,%esp
8010314b:	68 e0 95 10 80       	push   $0x801095e0
80103150:	e8 8a 0b 00 00       	call   80103cdf <release>
    return 0;
80103155:	83 c4 10             	add    $0x10,%esp
80103158:	bb 00 00 00 00       	mov    $0x0,%ebx
8010315d:	eb e2                	jmp    80103141 <allocproc+0xac>
    p->state = UNUSED;
8010315f:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
    return 0;
80103166:	bb 00 00 00 00       	mov    $0x0,%ebx
8010316b:	eb d4                	jmp    80103141 <allocproc+0xac>

8010316d <forkret>:
{
8010316d:	55                   	push   %ebp
8010316e:	89 e5                	mov    %esp,%ebp
80103170:	83 ec 14             	sub    $0x14,%esp
  release(&ptable.lock);
80103173:	68 e0 95 10 80       	push   $0x801095e0
80103178:	e8 62 0b 00 00       	call   80103cdf <release>
  if (first) {
8010317d:	83 c4 10             	add    $0x10,%esp
80103180:	83 3d 00 90 10 80 00 	cmpl   $0x0,0x80109000
80103187:	75 02                	jne    8010318b <forkret+0x1e>
}
80103189:	c9                   	leave  
8010318a:	c3                   	ret    
    first = 0;
8010318b:	c7 05 00 90 10 80 00 	movl   $0x0,0x80109000
80103192:	00 00 00 
    iinit(ROOTDEV);
80103195:	83 ec 0c             	sub    $0xc,%esp
80103198:	6a 01                	push   $0x1
8010319a:	e8 81 e1 ff ff       	call   80101320 <iinit>
    initlog(ROOTDEV);
8010319f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801031a6:	e8 ee f5 ff ff       	call   80102799 <initlog>
801031ab:	83 c4 10             	add    $0x10,%esp
}
801031ae:	eb d9                	jmp    80103189 <forkret+0x1c>

801031b0 <pinit>:
{
801031b0:	55                   	push   %ebp
801031b1:	89 e5                	mov    %esp,%ebp
801031b3:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
801031b6:	68 35 6a 10 80       	push   $0x80106a35
801031bb:	68 e0 95 10 80       	push   $0x801095e0
801031c0:	e8 79 09 00 00       	call   80103b3e <initlock>
}
801031c5:	83 c4 10             	add    $0x10,%esp
801031c8:	c9                   	leave  
801031c9:	c3                   	ret    

801031ca <mycpu>:
{
801031ca:	55                   	push   %ebp
801031cb:	89 e5                	mov    %esp,%ebp
801031cd:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801031d0:	9c                   	pushf  
801031d1:	58                   	pop    %eax
  if(readeflags()&FL_IF)
801031d2:	f6 c4 02             	test   $0x2,%ah
801031d5:	75 28                	jne    801031ff <mycpu+0x35>
  apicid = lapicid();
801031d7:	e8 d6 f1 ff ff       	call   801023b2 <lapicid>
  for (i = 0; i < ncpu; ++i) {
801031dc:	ba 00 00 00 00       	mov    $0x0,%edx
801031e1:	39 15 60 3d 11 80    	cmp    %edx,0x80113d60
801031e7:	7e 23                	jle    8010320c <mycpu+0x42>
    if (cpus[i].apicid == apicid) {
801031e9:	69 ca b0 00 00 00    	imul   $0xb0,%edx,%ecx
801031ef:	0f b6 89 e0 37 11 80 	movzbl -0x7feec820(%ecx),%ecx
801031f6:	39 c1                	cmp    %eax,%ecx
801031f8:	74 1f                	je     80103219 <mycpu+0x4f>
  for (i = 0; i < ncpu; ++i) {
801031fa:	83 c2 01             	add    $0x1,%edx
801031fd:	eb e2                	jmp    801031e1 <mycpu+0x17>
    panic("mycpu called with interrupts enabled\n");
801031ff:	83 ec 0c             	sub    $0xc,%esp
80103202:	68 20 6b 10 80       	push   $0x80106b20
80103207:	e8 3c d1 ff ff       	call   80100348 <panic>
  panic("unknown apicid\n");
8010320c:	83 ec 0c             	sub    $0xc,%esp
8010320f:	68 3c 6a 10 80       	push   $0x80106a3c
80103214:	e8 2f d1 ff ff       	call   80100348 <panic>
      return &cpus[i];
80103219:	69 c2 b0 00 00 00    	imul   $0xb0,%edx,%eax
8010321f:	05 e0 37 11 80       	add    $0x801137e0,%eax
}
80103224:	c9                   	leave  
80103225:	c3                   	ret    

80103226 <cpuid>:
cpuid() {
80103226:	55                   	push   %ebp
80103227:	89 e5                	mov    %esp,%ebp
80103229:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
8010322c:	e8 99 ff ff ff       	call   801031ca <mycpu>
80103231:	2d e0 37 11 80       	sub    $0x801137e0,%eax
80103236:	c1 f8 04             	sar    $0x4,%eax
80103239:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
8010323f:	c9                   	leave  
80103240:	c3                   	ret    

80103241 <myproc>:
myproc(void) {
80103241:	55                   	push   %ebp
80103242:	89 e5                	mov    %esp,%ebp
80103244:	53                   	push   %ebx
80103245:	83 ec 04             	sub    $0x4,%esp
  pushcli();
80103248:	e8 50 09 00 00       	call   80103b9d <pushcli>
  c = mycpu();
8010324d:	e8 78 ff ff ff       	call   801031ca <mycpu>
  p = c->proc;
80103252:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103258:	e8 7d 09 00 00       	call   80103bda <popcli>
}
8010325d:	89 d8                	mov    %ebx,%eax
8010325f:	83 c4 04             	add    $0x4,%esp
80103262:	5b                   	pop    %ebx
80103263:	5d                   	pop    %ebp
80103264:	c3                   	ret    

80103265 <userinit>:
{
80103265:	55                   	push   %ebp
80103266:	89 e5                	mov    %esp,%ebp
80103268:	53                   	push   %ebx
80103269:	83 ec 04             	sub    $0x4,%esp
  p = allocproc();
8010326c:	e8 24 fe ff ff       	call   80103095 <allocproc>
80103271:	89 c3                	mov    %eax,%ebx
  initproc = p;
80103273:	a3 c0 95 10 80       	mov    %eax,0x801095c0
  if((p->pgdir = setupkvm()) == 0)
80103278:	e8 1c 30 00 00       	call   80106299 <setupkvm>
8010327d:	89 43 08             	mov    %eax,0x8(%ebx)
80103280:	85 c0                	test   %eax,%eax
80103282:	0f 84 b8 00 00 00    	je     80103340 <userinit+0xdb>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103288:	83 ec 04             	sub    $0x4,%esp
8010328b:	68 2c 00 00 00       	push   $0x2c
80103290:	68 60 94 10 80       	push   $0x80109460
80103295:	50                   	push   %eax
80103296:	e8 09 2d 00 00       	call   80105fa4 <inituvm>
  p->sz = PGSIZE;
8010329b:	c7 43 04 00 10 00 00 	movl   $0x1000,0x4(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
801032a2:	83 c4 0c             	add    $0xc,%esp
801032a5:	6a 4c                	push   $0x4c
801032a7:	6a 00                	push   $0x0
801032a9:	ff 73 1c             	pushl  0x1c(%ebx)
801032ac:	e8 75 0a 00 00       	call   80103d26 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801032b1:	8b 43 1c             	mov    0x1c(%ebx),%eax
801032b4:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801032ba:	8b 43 1c             	mov    0x1c(%ebx),%eax
801032bd:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
801032c3:	8b 43 1c             	mov    0x1c(%ebx),%eax
801032c6:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
801032ca:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801032ce:	8b 43 1c             	mov    0x1c(%ebx),%eax
801032d1:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
801032d5:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801032d9:	8b 43 1c             	mov    0x1c(%ebx),%eax
801032dc:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801032e3:	8b 43 1c             	mov    0x1c(%ebx),%eax
801032e6:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801032ed:	8b 43 1c             	mov    0x1c(%ebx),%eax
801032f0:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
801032f7:	8d 43 70             	lea    0x70(%ebx),%eax
801032fa:	83 c4 0c             	add    $0xc,%esp
801032fd:	6a 10                	push   $0x10
801032ff:	68 65 6a 10 80       	push   $0x80106a65
80103304:	50                   	push   %eax
80103305:	e8 83 0b 00 00       	call   80103e8d <safestrcpy>
  p->cwd = namei("/");
8010330a:	c7 04 24 6e 6a 10 80 	movl   $0x80106a6e,(%esp)
80103311:	e8 ff e8 ff ff       	call   80101c15 <namei>
80103316:	89 43 6c             	mov    %eax,0x6c(%ebx)
  acquire(&ptable.lock);
80103319:	c7 04 24 e0 95 10 80 	movl   $0x801095e0,(%esp)
80103320:	e8 55 09 00 00       	call   80103c7a <acquire>
  p->state = RUNNABLE;
80103325:	c7 43 10 03 00 00 00 	movl   $0x3,0x10(%ebx)
  release(&ptable.lock);
8010332c:	c7 04 24 e0 95 10 80 	movl   $0x801095e0,(%esp)
80103333:	e8 a7 09 00 00       	call   80103cdf <release>
}
80103338:	83 c4 10             	add    $0x10,%esp
8010333b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010333e:	c9                   	leave  
8010333f:	c3                   	ret    
    panic("userinit: out of memory?");
80103340:	83 ec 0c             	sub    $0xc,%esp
80103343:	68 4c 6a 10 80       	push   $0x80106a4c
80103348:	e8 fb cf ff ff       	call   80100348 <panic>

8010334d <growproc>:
{
8010334d:	55                   	push   %ebp
8010334e:	89 e5                	mov    %esp,%ebp
80103350:	56                   	push   %esi
80103351:	53                   	push   %ebx
80103352:	8b 75 08             	mov    0x8(%ebp),%esi
  struct proc *curproc = myproc();
80103355:	e8 e7 fe ff ff       	call   80103241 <myproc>
8010335a:	89 c3                	mov    %eax,%ebx
  sz = curproc->sz;
8010335c:	8b 40 04             	mov    0x4(%eax),%eax
  if(n > 0){
8010335f:	85 f6                	test   %esi,%esi
80103361:	7f 21                	jg     80103384 <growproc+0x37>
  } else if(n < 0){
80103363:	85 f6                	test   %esi,%esi
80103365:	79 33                	jns    8010339a <growproc+0x4d>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103367:	83 ec 04             	sub    $0x4,%esp
8010336a:	01 c6                	add    %eax,%esi
8010336c:	56                   	push   %esi
8010336d:	50                   	push   %eax
8010336e:	ff 73 08             	pushl  0x8(%ebx)
80103371:	e8 37 2d 00 00       	call   801060ad <deallocuvm>
80103376:	83 c4 10             	add    $0x10,%esp
80103379:	85 c0                	test   %eax,%eax
8010337b:	75 1d                	jne    8010339a <growproc+0x4d>
      return -1;
8010337d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103382:	eb 2a                	jmp    801033ae <growproc+0x61>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103384:	83 ec 04             	sub    $0x4,%esp
80103387:	01 c6                	add    %eax,%esi
80103389:	56                   	push   %esi
8010338a:	50                   	push   %eax
8010338b:	ff 73 08             	pushl  0x8(%ebx)
8010338e:	e8 ac 2d 00 00       	call   8010613f <allocuvm>
80103393:	83 c4 10             	add    $0x10,%esp
80103396:	85 c0                	test   %eax,%eax
80103398:	74 1b                	je     801033b5 <growproc+0x68>
  curproc->sz = sz;
8010339a:	89 43 04             	mov    %eax,0x4(%ebx)
  switchuvm(curproc);
8010339d:	83 ec 0c             	sub    $0xc,%esp
801033a0:	53                   	push   %ebx
801033a1:	e8 e6 2a 00 00       	call   80105e8c <switchuvm>
  return 0;
801033a6:	83 c4 10             	add    $0x10,%esp
801033a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801033ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
801033b1:	5b                   	pop    %ebx
801033b2:	5e                   	pop    %esi
801033b3:	5d                   	pop    %ebp
801033b4:	c3                   	ret    
      return -1;
801033b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801033ba:	eb f2                	jmp    801033ae <growproc+0x61>

801033bc <fork>:
{
801033bc:	55                   	push   %ebp
801033bd:	89 e5                	mov    %esp,%ebp
801033bf:	57                   	push   %edi
801033c0:	56                   	push   %esi
801033c1:	53                   	push   %ebx
801033c2:	83 ec 1c             	sub    $0x1c,%esp
  struct proc *curproc = myproc();
801033c5:	e8 77 fe ff ff       	call   80103241 <myproc>
801033ca:	89 c3                	mov    %eax,%ebx
  if((np = allocproc()) == 0){
801033cc:	e8 c4 fc ff ff       	call   80103095 <allocproc>
801033d1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801033d4:	85 c0                	test   %eax,%eax
801033d6:	0f 84 e3 00 00 00    	je     801034bf <fork+0x103>
801033dc:	89 c7                	mov    %eax,%edi
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
801033de:	83 ec 08             	sub    $0x8,%esp
801033e1:	ff 73 04             	pushl  0x4(%ebx)
801033e4:	ff 73 08             	pushl  0x8(%ebx)
801033e7:	e8 5e 2f 00 00       	call   8010634a <copyuvm>
801033ec:	89 47 08             	mov    %eax,0x8(%edi)
801033ef:	83 c4 10             	add    $0x10,%esp
801033f2:	85 c0                	test   %eax,%eax
801033f4:	74 2c                	je     80103422 <fork+0x66>
  np->sz = curproc->sz;
801033f6:	8b 43 04             	mov    0x4(%ebx),%eax
801033f9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801033fc:	89 41 04             	mov    %eax,0x4(%ecx)
  np->parent = curproc;
801033ff:	89 c8                	mov    %ecx,%eax
80103401:	89 59 18             	mov    %ebx,0x18(%ecx)
  *np->tf = *curproc->tf;
80103404:	8b 73 1c             	mov    0x1c(%ebx),%esi
80103407:	8b 79 1c             	mov    0x1c(%ecx),%edi
8010340a:	b9 13 00 00 00       	mov    $0x13,%ecx
8010340f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  np->tf->eax = 0;
80103411:	8b 40 1c             	mov    0x1c(%eax),%eax
80103414:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
8010341b:	be 00 00 00 00       	mov    $0x0,%esi
80103420:	eb 29                	jmp    8010344b <fork+0x8f>
    kfree(np->kstack);
80103422:	83 ec 0c             	sub    $0xc,%esp
80103425:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80103428:	ff 73 0c             	pushl  0xc(%ebx)
8010342b:	e8 a8 eb ff ff       	call   80101fd8 <kfree>
    np->kstack = 0;
80103430:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    np->state = UNUSED;
80103437:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
    return -1;
8010343e:	83 c4 10             	add    $0x10,%esp
80103441:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103446:	eb 6f                	jmp    801034b7 <fork+0xfb>
  for(i = 0; i < NOFILE; i++)
80103448:	83 c6 01             	add    $0x1,%esi
8010344b:	83 fe 0f             	cmp    $0xf,%esi
8010344e:	7f 1d                	jg     8010346d <fork+0xb1>
    if(curproc->ofile[i])
80103450:	8b 44 b3 2c          	mov    0x2c(%ebx,%esi,4),%eax
80103454:	85 c0                	test   %eax,%eax
80103456:	74 f0                	je     80103448 <fork+0x8c>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103458:	83 ec 0c             	sub    $0xc,%esp
8010345b:	50                   	push   %eax
8010345c:	e8 61 d8 ff ff       	call   80100cc2 <filedup>
80103461:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103464:	89 44 b2 2c          	mov    %eax,0x2c(%edx,%esi,4)
80103468:	83 c4 10             	add    $0x10,%esp
8010346b:	eb db                	jmp    80103448 <fork+0x8c>
  np->cwd = idup(curproc->cwd);
8010346d:	83 ec 0c             	sub    $0xc,%esp
80103470:	ff 73 6c             	pushl  0x6c(%ebx)
80103473:	e8 0d e1 ff ff       	call   80101585 <idup>
80103478:	8b 7d e4             	mov    -0x1c(%ebp),%edi
8010347b:	89 47 6c             	mov    %eax,0x6c(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
8010347e:	83 c3 70             	add    $0x70,%ebx
80103481:	8d 47 70             	lea    0x70(%edi),%eax
80103484:	83 c4 0c             	add    $0xc,%esp
80103487:	6a 10                	push   $0x10
80103489:	53                   	push   %ebx
8010348a:	50                   	push   %eax
8010348b:	e8 fd 09 00 00       	call   80103e8d <safestrcpy>
  pid = np->pid;
80103490:	8b 5f 14             	mov    0x14(%edi),%ebx
  acquire(&ptable.lock);
80103493:	c7 04 24 e0 95 10 80 	movl   $0x801095e0,(%esp)
8010349a:	e8 db 07 00 00       	call   80103c7a <acquire>
  np->state = RUNNABLE;
8010349f:	c7 47 10 03 00 00 00 	movl   $0x3,0x10(%edi)
  release(&ptable.lock);
801034a6:	c7 04 24 e0 95 10 80 	movl   $0x801095e0,(%esp)
801034ad:	e8 2d 08 00 00       	call   80103cdf <release>
  return pid;
801034b2:	89 d8                	mov    %ebx,%eax
801034b4:	83 c4 10             	add    $0x10,%esp
}
801034b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
801034ba:	5b                   	pop    %ebx
801034bb:	5e                   	pop    %esi
801034bc:	5f                   	pop    %edi
801034bd:	5d                   	pop    %ebp
801034be:	c3                   	ret    
    return -1;
801034bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801034c4:	eb f1                	jmp    801034b7 <fork+0xfb>

801034c6 <scheduler>:
{
801034c6:	55                   	push   %ebp
801034c7:	89 e5                	mov    %esp,%ebp
801034c9:	57                   	push   %edi
801034ca:	56                   	push   %esi
801034cb:	53                   	push   %ebx
801034cc:	83 ec 0c             	sub    $0xc,%esp
  struct cpu *c = mycpu();
801034cf:	e8 f6 fc ff ff       	call   801031ca <mycpu>
801034d4:	89 c6                	mov    %eax,%esi
  c->proc = 0;
801034d6:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801034dd:	00 00 00 
801034e0:	eb 65                	jmp    80103547 <scheduler+0x81>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801034e2:	83 eb 80             	sub    $0xffffff80,%ebx
801034e5:	81 fb 14 b6 10 80    	cmp    $0x8010b614,%ebx
801034eb:	73 44                	jae    80103531 <scheduler+0x6b>
      if(p->state != RUNNABLE)
801034ed:	83 7b 10 03          	cmpl   $0x3,0x10(%ebx)
801034f1:	75 ef                	jne    801034e2 <scheduler+0x1c>
      c->proc = p;
801034f3:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      switchuvm(p);
801034f9:	83 ec 0c             	sub    $0xc,%esp
801034fc:	53                   	push   %ebx
801034fd:	e8 8a 29 00 00       	call   80105e8c <switchuvm>
      p->state = RUNNING;
80103502:	c7 43 10 04 00 00 00 	movl   $0x4,0x10(%ebx)
      swtch(&(c->scheduler), p->context);
80103509:	83 c4 08             	add    $0x8,%esp
8010350c:	ff 73 20             	pushl  0x20(%ebx)
8010350f:	8d 46 04             	lea    0x4(%esi),%eax
80103512:	50                   	push   %eax
80103513:	e8 c8 09 00 00       	call   80103ee0 <swtch>
      switchkvm();
80103518:	e8 5d 29 00 00       	call   80105e7a <switchkvm>
      c->proc = 0;
8010351d:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
80103524:	00 00 00 
80103527:	83 c4 10             	add    $0x10,%esp
      idle = 0;  // not idle this timeslice
8010352a:	bf 00 00 00 00       	mov    $0x0,%edi
8010352f:	eb b1                	jmp    801034e2 <scheduler+0x1c>
    release(&ptable.lock);
80103531:	83 ec 0c             	sub    $0xc,%esp
80103534:	68 e0 95 10 80       	push   $0x801095e0
80103539:	e8 a1 07 00 00       	call   80103cdf <release>
    if (idle) {
8010353e:	83 c4 10             	add    $0x10,%esp
80103541:	85 ff                	test   %edi,%edi
80103543:	74 02                	je     80103547 <scheduler+0x81>
  asm volatile("sti");
80103545:	fb                   	sti    

// hlt() added by Noah Zentzis, Fall 2016.
static inline void
hlt()
{
  asm volatile("hlt");
80103546:	f4                   	hlt    
80103547:	fb                   	sti    
    acquire(&ptable.lock);
80103548:	83 ec 0c             	sub    $0xc,%esp
8010354b:	68 e0 95 10 80       	push   $0x801095e0
80103550:	e8 25 07 00 00       	call   80103c7a <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103555:	83 c4 10             	add    $0x10,%esp
    idle = 1;  // assume idle unless we schedule a process
80103558:	bf 01 00 00 00       	mov    $0x1,%edi
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010355d:	bb 14 96 10 80       	mov    $0x80109614,%ebx
80103562:	eb 81                	jmp    801034e5 <scheduler+0x1f>

80103564 <sched>:
{
80103564:	55                   	push   %ebp
80103565:	89 e5                	mov    %esp,%ebp
80103567:	56                   	push   %esi
80103568:	53                   	push   %ebx
  struct proc *p = myproc();
80103569:	e8 d3 fc ff ff       	call   80103241 <myproc>
8010356e:	89 c3                	mov    %eax,%ebx
  if(!holding(&ptable.lock))
80103570:	83 ec 0c             	sub    $0xc,%esp
80103573:	68 e0 95 10 80       	push   $0x801095e0
80103578:	e8 bd 06 00 00       	call   80103c3a <holding>
8010357d:	83 c4 10             	add    $0x10,%esp
80103580:	85 c0                	test   %eax,%eax
80103582:	74 4f                	je     801035d3 <sched+0x6f>
  if(mycpu()->ncli != 1)
80103584:	e8 41 fc ff ff       	call   801031ca <mycpu>
80103589:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
80103590:	75 4e                	jne    801035e0 <sched+0x7c>
  if(p->state == RUNNING)
80103592:	83 7b 10 04          	cmpl   $0x4,0x10(%ebx)
80103596:	74 55                	je     801035ed <sched+0x89>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103598:	9c                   	pushf  
80103599:	58                   	pop    %eax
  if(readeflags()&FL_IF)
8010359a:	f6 c4 02             	test   $0x2,%ah
8010359d:	75 5b                	jne    801035fa <sched+0x96>
  intena = mycpu()->intena;
8010359f:	e8 26 fc ff ff       	call   801031ca <mycpu>
801035a4:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
801035aa:	e8 1b fc ff ff       	call   801031ca <mycpu>
801035af:	83 ec 08             	sub    $0x8,%esp
801035b2:	ff 70 04             	pushl  0x4(%eax)
801035b5:	83 c3 20             	add    $0x20,%ebx
801035b8:	53                   	push   %ebx
801035b9:	e8 22 09 00 00       	call   80103ee0 <swtch>
  mycpu()->intena = intena;
801035be:	e8 07 fc ff ff       	call   801031ca <mycpu>
801035c3:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
801035c9:	83 c4 10             	add    $0x10,%esp
801035cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
801035cf:	5b                   	pop    %ebx
801035d0:	5e                   	pop    %esi
801035d1:	5d                   	pop    %ebp
801035d2:	c3                   	ret    
    panic("sched ptable.lock");
801035d3:	83 ec 0c             	sub    $0xc,%esp
801035d6:	68 70 6a 10 80       	push   $0x80106a70
801035db:	e8 68 cd ff ff       	call   80100348 <panic>
    panic("sched locks");
801035e0:	83 ec 0c             	sub    $0xc,%esp
801035e3:	68 82 6a 10 80       	push   $0x80106a82
801035e8:	e8 5b cd ff ff       	call   80100348 <panic>
    panic("sched running");
801035ed:	83 ec 0c             	sub    $0xc,%esp
801035f0:	68 8e 6a 10 80       	push   $0x80106a8e
801035f5:	e8 4e cd ff ff       	call   80100348 <panic>
    panic("sched interruptible");
801035fa:	83 ec 0c             	sub    $0xc,%esp
801035fd:	68 9c 6a 10 80       	push   $0x80106a9c
80103602:	e8 41 cd ff ff       	call   80100348 <panic>

80103607 <exit>:
{
80103607:	55                   	push   %ebp
80103608:	89 e5                	mov    %esp,%ebp
8010360a:	56                   	push   %esi
8010360b:	53                   	push   %ebx
  struct proc *curproc = myproc();
8010360c:	e8 30 fc ff ff       	call   80103241 <myproc>
  if(curproc == initproc)
80103611:	39 05 c0 95 10 80    	cmp    %eax,0x801095c0
80103617:	74 09                	je     80103622 <exit+0x1b>
80103619:	89 c6                	mov    %eax,%esi
  for(fd = 0; fd < NOFILE; fd++){
8010361b:	bb 00 00 00 00       	mov    $0x0,%ebx
80103620:	eb 10                	jmp    80103632 <exit+0x2b>
    panic("init exiting");
80103622:	83 ec 0c             	sub    $0xc,%esp
80103625:	68 b0 6a 10 80       	push   $0x80106ab0
8010362a:	e8 19 cd ff ff       	call   80100348 <panic>
  for(fd = 0; fd < NOFILE; fd++){
8010362f:	83 c3 01             	add    $0x1,%ebx
80103632:	83 fb 0f             	cmp    $0xf,%ebx
80103635:	7f 1e                	jg     80103655 <exit+0x4e>
    if(curproc->ofile[fd]){
80103637:	8b 44 9e 2c          	mov    0x2c(%esi,%ebx,4),%eax
8010363b:	85 c0                	test   %eax,%eax
8010363d:	74 f0                	je     8010362f <exit+0x28>
      fileclose(curproc->ofile[fd]);
8010363f:	83 ec 0c             	sub    $0xc,%esp
80103642:	50                   	push   %eax
80103643:	e8 bf d6 ff ff       	call   80100d07 <fileclose>
      curproc->ofile[fd] = 0;
80103648:	c7 44 9e 2c 00 00 00 	movl   $0x0,0x2c(%esi,%ebx,4)
8010364f:	00 
80103650:	83 c4 10             	add    $0x10,%esp
80103653:	eb da                	jmp    8010362f <exit+0x28>
  begin_op();
80103655:	e8 88 f1 ff ff       	call   801027e2 <begin_op>
  iput(curproc->cwd);
8010365a:	83 ec 0c             	sub    $0xc,%esp
8010365d:	ff 76 6c             	pushl  0x6c(%esi)
80103660:	e8 57 e0 ff ff       	call   801016bc <iput>
  end_op();
80103665:	e8 f2 f1 ff ff       	call   8010285c <end_op>
  curproc->cwd = 0;
8010366a:	c7 46 6c 00 00 00 00 	movl   $0x0,0x6c(%esi)
  acquire(&ptable.lock);
80103671:	c7 04 24 e0 95 10 80 	movl   $0x801095e0,(%esp)
80103678:	e8 fd 05 00 00       	call   80103c7a <acquire>
  wakeup1(curproc->parent);
8010367d:	8b 46 18             	mov    0x18(%esi),%eax
80103680:	e8 e5 f9 ff ff       	call   8010306a <wakeup1>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103685:	83 c4 10             	add    $0x10,%esp
80103688:	bb 14 96 10 80       	mov    $0x80109614,%ebx
8010368d:	eb 03                	jmp    80103692 <exit+0x8b>
8010368f:	83 eb 80             	sub    $0xffffff80,%ebx
80103692:	81 fb 14 b6 10 80    	cmp    $0x8010b614,%ebx
80103698:	73 1a                	jae    801036b4 <exit+0xad>
    if(p->parent == curproc){
8010369a:	39 73 18             	cmp    %esi,0x18(%ebx)
8010369d:	75 f0                	jne    8010368f <exit+0x88>
      p->parent = initproc;
8010369f:	a1 c0 95 10 80       	mov    0x801095c0,%eax
801036a4:	89 43 18             	mov    %eax,0x18(%ebx)
      if(p->state == ZOMBIE)
801036a7:	83 7b 10 05          	cmpl   $0x5,0x10(%ebx)
801036ab:	75 e2                	jne    8010368f <exit+0x88>
        wakeup1(initproc);
801036ad:	e8 b8 f9 ff ff       	call   8010306a <wakeup1>
801036b2:	eb db                	jmp    8010368f <exit+0x88>
  curproc->state = ZOMBIE;
801036b4:	c7 46 10 05 00 00 00 	movl   $0x5,0x10(%esi)
  curproc->sz = 0;
801036bb:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
  sched();
801036c2:	e8 9d fe ff ff       	call   80103564 <sched>
  panic("zombie exit");
801036c7:	83 ec 0c             	sub    $0xc,%esp
801036ca:	68 bd 6a 10 80       	push   $0x80106abd
801036cf:	e8 74 cc ff ff       	call   80100348 <panic>

801036d4 <yield>:
{
801036d4:	55                   	push   %ebp
801036d5:	89 e5                	mov    %esp,%ebp
801036d7:	53                   	push   %ebx
801036d8:	83 ec 04             	sub    $0x4,%esp
  struct proc *curproc = myproc();
801036db:	e8 61 fb ff ff       	call   80103241 <myproc>
801036e0:	89 c3                	mov    %eax,%ebx
  acquire(&ptable.lock);  //DOC: yieldlock
801036e2:	83 ec 0c             	sub    $0xc,%esp
801036e5:	68 e0 95 10 80       	push   $0x801095e0
801036ea:	e8 8b 05 00 00       	call   80103c7a <acquire>
  curproc->state = RUNNABLE;
801036ef:	c7 43 10 03 00 00 00 	movl   $0x3,0x10(%ebx)
  sched();
801036f6:	e8 69 fe ff ff       	call   80103564 <sched>
  release(&ptable.lock);
801036fb:	c7 04 24 e0 95 10 80 	movl   $0x801095e0,(%esp)
80103702:	e8 d8 05 00 00       	call   80103cdf <release>
}
80103707:	83 c4 10             	add    $0x10,%esp
8010370a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010370d:	c9                   	leave  
8010370e:	c3                   	ret    

8010370f <sleep>:
{
8010370f:	55                   	push   %ebp
80103710:	89 e5                	mov    %esp,%ebp
80103712:	56                   	push   %esi
80103713:	53                   	push   %ebx
80103714:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct proc *p = myproc();
80103717:	e8 25 fb ff ff       	call   80103241 <myproc>
  if(p == 0)
8010371c:	85 c0                	test   %eax,%eax
8010371e:	74 72                	je     80103792 <sleep+0x83>
80103720:	89 c3                	mov    %eax,%ebx
  if(lk != &ptable.lock){  //DOC: sleeplock0
80103722:	81 fe e0 95 10 80    	cmp    $0x801095e0,%esi
80103728:	74 20                	je     8010374a <sleep+0x3b>
    acquire(&ptable.lock);  //DOC: sleeplock1
8010372a:	83 ec 0c             	sub    $0xc,%esp
8010372d:	68 e0 95 10 80       	push   $0x801095e0
80103732:	e8 43 05 00 00       	call   80103c7a <acquire>
    if (lk) release(lk);
80103737:	83 c4 10             	add    $0x10,%esp
8010373a:	85 f6                	test   %esi,%esi
8010373c:	74 0c                	je     8010374a <sleep+0x3b>
8010373e:	83 ec 0c             	sub    $0xc,%esp
80103741:	56                   	push   %esi
80103742:	e8 98 05 00 00       	call   80103cdf <release>
80103747:	83 c4 10             	add    $0x10,%esp
  p->chan = chan;
8010374a:	8b 45 08             	mov    0x8(%ebp),%eax
8010374d:	89 43 24             	mov    %eax,0x24(%ebx)
  p->state = SLEEPING;
80103750:	c7 43 10 02 00 00 00 	movl   $0x2,0x10(%ebx)
  sched();
80103757:	e8 08 fe ff ff       	call   80103564 <sched>
  p->chan = 0;
8010375c:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
  if(lk != &ptable.lock){  //DOC: sleeplock2
80103763:	81 fe e0 95 10 80    	cmp    $0x801095e0,%esi
80103769:	74 20                	je     8010378b <sleep+0x7c>
    release(&ptable.lock);
8010376b:	83 ec 0c             	sub    $0xc,%esp
8010376e:	68 e0 95 10 80       	push   $0x801095e0
80103773:	e8 67 05 00 00       	call   80103cdf <release>
    if (lk) acquire(lk);
80103778:	83 c4 10             	add    $0x10,%esp
8010377b:	85 f6                	test   %esi,%esi
8010377d:	74 0c                	je     8010378b <sleep+0x7c>
8010377f:	83 ec 0c             	sub    $0xc,%esp
80103782:	56                   	push   %esi
80103783:	e8 f2 04 00 00       	call   80103c7a <acquire>
80103788:	83 c4 10             	add    $0x10,%esp
}
8010378b:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010378e:	5b                   	pop    %ebx
8010378f:	5e                   	pop    %esi
80103790:	5d                   	pop    %ebp
80103791:	c3                   	ret    
    panic("sleep");
80103792:	83 ec 0c             	sub    $0xc,%esp
80103795:	68 c9 6a 10 80       	push   $0x80106ac9
8010379a:	e8 a9 cb ff ff       	call   80100348 <panic>

8010379f <wait>:
{
8010379f:	55                   	push   %ebp
801037a0:	89 e5                	mov    %esp,%ebp
801037a2:	56                   	push   %esi
801037a3:	53                   	push   %ebx
  struct proc *curproc = myproc();
801037a4:	e8 98 fa ff ff       	call   80103241 <myproc>
801037a9:	89 c6                	mov    %eax,%esi
  acquire(&ptable.lock);
801037ab:	83 ec 0c             	sub    $0xc,%esp
801037ae:	68 e0 95 10 80       	push   $0x801095e0
801037b3:	e8 c2 04 00 00       	call   80103c7a <acquire>
801037b8:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801037bb:	b8 00 00 00 00       	mov    $0x0,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801037c0:	bb 14 96 10 80       	mov    $0x80109614,%ebx
801037c5:	eb 5b                	jmp    80103822 <wait+0x83>
        pid = p->pid;
801037c7:	8b 73 14             	mov    0x14(%ebx),%esi
        kfree(p->kstack);
801037ca:	83 ec 0c             	sub    $0xc,%esp
801037cd:	ff 73 0c             	pushl  0xc(%ebx)
801037d0:	e8 03 e8 ff ff       	call   80101fd8 <kfree>
        p->kstack = 0;
801037d5:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        freevm(p->pgdir);
801037dc:	83 c4 04             	add    $0x4,%esp
801037df:	ff 73 08             	pushl  0x8(%ebx)
801037e2:	e8 42 2a 00 00       	call   80106229 <freevm>
        p->pid = 0;
801037e7:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->parent = 0;
801037ee:	c7 43 18 00 00 00 00 	movl   $0x0,0x18(%ebx)
        p->name[0] = 0;
801037f5:	c6 43 70 00          	movb   $0x0,0x70(%ebx)
        p->killed = 0;
801037f9:	c7 43 28 00 00 00 00 	movl   $0x0,0x28(%ebx)
        p->state = UNUSED;
80103800:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        release(&ptable.lock);
80103807:	c7 04 24 e0 95 10 80 	movl   $0x801095e0,(%esp)
8010380e:	e8 cc 04 00 00       	call   80103cdf <release>
        return pid;
80103813:	89 f0                	mov    %esi,%eax
80103815:	83 c4 10             	add    $0x10,%esp
}
80103818:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010381b:	5b                   	pop    %ebx
8010381c:	5e                   	pop    %esi
8010381d:	5d                   	pop    %ebp
8010381e:	c3                   	ret    
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010381f:	83 eb 80             	sub    $0xffffff80,%ebx
80103822:	81 fb 14 b6 10 80    	cmp    $0x8010b614,%ebx
80103828:	73 12                	jae    8010383c <wait+0x9d>
      if(p->parent != curproc)
8010382a:	39 73 18             	cmp    %esi,0x18(%ebx)
8010382d:	75 f0                	jne    8010381f <wait+0x80>
      if(p->state == ZOMBIE){
8010382f:	83 7b 10 05          	cmpl   $0x5,0x10(%ebx)
80103833:	74 92                	je     801037c7 <wait+0x28>
      havekids = 1;
80103835:	b8 01 00 00 00       	mov    $0x1,%eax
8010383a:	eb e3                	jmp    8010381f <wait+0x80>
    if(!havekids || curproc->killed){
8010383c:	85 c0                	test   %eax,%eax
8010383e:	74 06                	je     80103846 <wait+0xa7>
80103840:	83 7e 28 00          	cmpl   $0x0,0x28(%esi)
80103844:	74 17                	je     8010385d <wait+0xbe>
      release(&ptable.lock);
80103846:	83 ec 0c             	sub    $0xc,%esp
80103849:	68 e0 95 10 80       	push   $0x801095e0
8010384e:	e8 8c 04 00 00       	call   80103cdf <release>
      return -1;
80103853:	83 c4 10             	add    $0x10,%esp
80103856:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010385b:	eb bb                	jmp    80103818 <wait+0x79>
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
8010385d:	83 ec 08             	sub    $0x8,%esp
80103860:	68 e0 95 10 80       	push   $0x801095e0
80103865:	56                   	push   %esi
80103866:	e8 a4 fe ff ff       	call   8010370f <sleep>
    havekids = 0;
8010386b:	83 c4 10             	add    $0x10,%esp
8010386e:	e9 48 ff ff ff       	jmp    801037bb <wait+0x1c>

80103873 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80103873:	55                   	push   %ebp
80103874:	89 e5                	mov    %esp,%ebp
80103876:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
80103879:	68 e0 95 10 80       	push   $0x801095e0
8010387e:	e8 f7 03 00 00       	call   80103c7a <acquire>
  wakeup1(chan);
80103883:	8b 45 08             	mov    0x8(%ebp),%eax
80103886:	e8 df f7 ff ff       	call   8010306a <wakeup1>
  release(&ptable.lock);
8010388b:	c7 04 24 e0 95 10 80 	movl   $0x801095e0,(%esp)
80103892:	e8 48 04 00 00       	call   80103cdf <release>
}
80103897:	83 c4 10             	add    $0x10,%esp
8010389a:	c9                   	leave  
8010389b:	c3                   	ret    

8010389c <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
8010389c:	55                   	push   %ebp
8010389d:	89 e5                	mov    %esp,%ebp
8010389f:	53                   	push   %ebx
801038a0:	83 ec 10             	sub    $0x10,%esp
801038a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
801038a6:	68 e0 95 10 80       	push   $0x801095e0
801038ab:	e8 ca 03 00 00       	call   80103c7a <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801038b0:	83 c4 10             	add    $0x10,%esp
801038b3:	b8 14 96 10 80       	mov    $0x80109614,%eax
801038b8:	3d 14 b6 10 80       	cmp    $0x8010b614,%eax
801038bd:	73 3a                	jae    801038f9 <kill+0x5d>
    if(p->pid == pid){
801038bf:	39 58 14             	cmp    %ebx,0x14(%eax)
801038c2:	74 05                	je     801038c9 <kill+0x2d>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801038c4:	83 e8 80             	sub    $0xffffff80,%eax
801038c7:	eb ef                	jmp    801038b8 <kill+0x1c>
      p->killed = 1;
801038c9:	c7 40 28 01 00 00 00 	movl   $0x1,0x28(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801038d0:	83 78 10 02          	cmpl   $0x2,0x10(%eax)
801038d4:	74 1a                	je     801038f0 <kill+0x54>
        p->state = RUNNABLE;
      release(&ptable.lock);
801038d6:	83 ec 0c             	sub    $0xc,%esp
801038d9:	68 e0 95 10 80       	push   $0x801095e0
801038de:	e8 fc 03 00 00       	call   80103cdf <release>
      return 0;
801038e3:	83 c4 10             	add    $0x10,%esp
801038e6:	b8 00 00 00 00       	mov    $0x0,%eax
    }
  }
  release(&ptable.lock);
  return -1;
}
801038eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801038ee:	c9                   	leave  
801038ef:	c3                   	ret    
        p->state = RUNNABLE;
801038f0:	c7 40 10 03 00 00 00 	movl   $0x3,0x10(%eax)
801038f7:	eb dd                	jmp    801038d6 <kill+0x3a>
  release(&ptable.lock);
801038f9:	83 ec 0c             	sub    $0xc,%esp
801038fc:	68 e0 95 10 80       	push   $0x801095e0
80103901:	e8 d9 03 00 00       	call   80103cdf <release>
  return -1;
80103906:	83 c4 10             	add    $0x10,%esp
80103909:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010390e:	eb db                	jmp    801038eb <kill+0x4f>

80103910 <procdumpP1>:
  return;
}
#elif defined(CS333_P1)
void
procdumpP1(struct proc *p, char *state_string)
{
80103910:	55                   	push   %ebp
80103911:	89 e5                	mov    %esp,%ebp
80103913:	57                   	push   %edi
80103914:	56                   	push   %esi
80103915:	53                   	push   %ebx
80103916:	83 ec 0c             	sub    $0xc,%esp
80103919:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int elapsed_s;
  int elapsed_ms;

  elapsed_ms = ticks - p->start_ticks;
8010391c:	8b 1d 80 45 11 80    	mov    0x80114580,%ebx
80103922:	2b 19                	sub    (%ecx),%ebx
  elapsed_s = elapsed_ms / 1000;
80103924:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
80103929:	89 d8                	mov    %ebx,%eax
8010392b:	f7 ea                	imul   %edx
8010392d:	c1 fa 06             	sar    $0x6,%edx
80103930:	89 d8                	mov    %ebx,%eax
80103932:	c1 f8 1f             	sar    $0x1f,%eax
80103935:	29 c2                	sub    %eax,%edx
  elapsed_ms = elapsed_ms % 1000;
80103937:	69 c2 e8 03 00 00    	imul   $0x3e8,%edx,%eax
8010393d:	29 c3                	sub    %eax,%ebx
8010393f:	89 d8                	mov    %ebx,%eax

  char* nol = "";
  if(elapsed_ms < 100 && elapsed_ms >= 10)
80103941:	8d 5b f6             	lea    -0xa(%ebx),%ebx
80103944:	83 fb 59             	cmp    $0x59,%ebx
80103947:	76 43                	jbe    8010398c <procdumpP1+0x7c>
  char* nol = "";
80103949:	bb ee 6a 10 80       	mov    $0x80106aee,%ebx
    nol = "0";
  if(elapsed_ms < 10)
8010394e:	83 f8 09             	cmp    $0x9,%eax
80103951:	7f 05                	jg     80103958 <procdumpP1+0x48>
  nol = "00";
80103953:	bb cf 6a 10 80       	mov    $0x80106acf,%ebx

  cprintf("%d\t%s\t%s%d.%s%d\t%s\t%d\t", 
  p->pid, p->name, "     ",elapsed_s, nol, elapsed_ms, states[p->state], p->sz);
80103958:	8d 71 70             	lea    0x70(%ecx),%esi
  cprintf("%d\t%s\t%s%d.%s%d\t%s\t%d\t", 
8010395b:	83 ec 0c             	sub    $0xc,%esp
8010395e:	ff 71 04             	pushl  0x4(%ecx)
80103961:	8b 79 10             	mov    0x10(%ecx),%edi
80103964:	ff 34 bd 74 6b 10 80 	pushl  -0x7fef948c(,%edi,4)
8010396b:	50                   	push   %eax
8010396c:	53                   	push   %ebx
8010396d:	52                   	push   %edx
8010396e:	68 d2 6a 10 80       	push   $0x80106ad2
80103973:	56                   	push   %esi
80103974:	ff 71 14             	pushl  0x14(%ecx)
80103977:	68 d8 6a 10 80       	push   $0x80106ad8
8010397c:	e8 8a cc ff ff       	call   8010060b <cprintf>
  return;
80103981:	83 c4 30             	add    $0x30,%esp
}
80103984:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103987:	5b                   	pop    %ebx
80103988:	5e                   	pop    %esi
80103989:	5f                   	pop    %edi
8010398a:	5d                   	pop    %ebp
8010398b:	c3                   	ret    
    nol = "0";
8010398c:	bb d0 6a 10 80       	mov    $0x80106ad0,%ebx
80103991:	eb bb                	jmp    8010394e <procdumpP1+0x3e>

80103993 <procdump>:
#endif

void
procdump(void)
{
80103993:	55                   	push   %ebp
80103994:	89 e5                	mov    %esp,%ebp
80103996:	56                   	push   %esi
80103997:	53                   	push   %ebx
80103998:	83 ec 3c             	sub    $0x3c,%esp
#define HEADER "\nPID\tName         Elapsed\tState\tSize\t PCs\n"
#else
#define HEADER "\n"
#endif

  cprintf(HEADER);  // not conditionally compiled as must work in all project states
8010399b:	68 48 6b 10 80       	push   $0x80106b48
801039a0:	e8 66 cc ff ff       	call   8010060b <cprintf>

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801039a5:	83 c4 10             	add    $0x10,%esp
801039a8:	bb 14 96 10 80       	mov    $0x80109614,%ebx
801039ad:	eb 2b                	jmp    801039da <procdump+0x47>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
801039af:	b8 ef 6a 10 80       	mov    $0x80106aef,%eax
    // see TODOs above this function
    // P2 and P3 are identical and the P4 change is minor
#if defined(CS333_P2)
    procdumpP2P3P4(p, state);
#elif defined(CS333_P1)
    procdumpP1(p, state);
801039b4:	83 ec 08             	sub    $0x8,%esp
801039b7:	50                   	push   %eax
801039b8:	53                   	push   %ebx
801039b9:	e8 52 ff ff ff       	call   80103910 <procdumpP1>
#else
    cprintf("%d\t%s\t%s\t", p->pid, p->name, state);
#endif

    if(p->state == SLEEPING){
801039be:	83 c4 10             	add    $0x10,%esp
801039c1:	83 7b 10 02          	cmpl   $0x2,0x10(%ebx)
801039c5:	74 39                	je     80103a00 <procdump+0x6d>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
801039c7:	83 ec 0c             	sub    $0xc,%esp
801039ca:	68 9b 6e 10 80       	push   $0x80106e9b
801039cf:	e8 37 cc ff ff       	call   8010060b <cprintf>
801039d4:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801039d7:	83 eb 80             	sub    $0xffffff80,%ebx
801039da:	81 fb 14 b6 10 80    	cmp    $0x8010b614,%ebx
801039e0:	73 61                	jae    80103a43 <procdump+0xb0>
    if(p->state == UNUSED)
801039e2:	8b 43 10             	mov    0x10(%ebx),%eax
801039e5:	85 c0                	test   %eax,%eax
801039e7:	74 ee                	je     801039d7 <procdump+0x44>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801039e9:	83 f8 05             	cmp    $0x5,%eax
801039ec:	77 c1                	ja     801039af <procdump+0x1c>
801039ee:	8b 04 85 74 6b 10 80 	mov    -0x7fef948c(,%eax,4),%eax
801039f5:	85 c0                	test   %eax,%eax
801039f7:	75 bb                	jne    801039b4 <procdump+0x21>
      state = "???";
801039f9:	b8 ef 6a 10 80       	mov    $0x80106aef,%eax
801039fe:	eb b4                	jmp    801039b4 <procdump+0x21>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80103a00:	8b 43 20             	mov    0x20(%ebx),%eax
80103a03:	8b 40 0c             	mov    0xc(%eax),%eax
80103a06:	83 c0 08             	add    $0x8,%eax
80103a09:	83 ec 08             	sub    $0x8,%esp
80103a0c:	8d 55 d0             	lea    -0x30(%ebp),%edx
80103a0f:	52                   	push   %edx
80103a10:	50                   	push   %eax
80103a11:	e8 43 01 00 00       	call   80103b59 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80103a16:	83 c4 10             	add    $0x10,%esp
80103a19:	be 00 00 00 00       	mov    $0x0,%esi
80103a1e:	eb 14                	jmp    80103a34 <procdump+0xa1>
        cprintf(" %p", pc[i]);
80103a20:	83 ec 08             	sub    $0x8,%esp
80103a23:	50                   	push   %eax
80103a24:	68 21 65 10 80       	push   $0x80106521
80103a29:	e8 dd cb ff ff       	call   8010060b <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
80103a2e:	83 c6 01             	add    $0x1,%esi
80103a31:	83 c4 10             	add    $0x10,%esp
80103a34:	83 fe 09             	cmp    $0x9,%esi
80103a37:	7f 8e                	jg     801039c7 <procdump+0x34>
80103a39:	8b 44 b5 d0          	mov    -0x30(%ebp,%esi,4),%eax
80103a3d:	85 c0                	test   %eax,%eax
80103a3f:	75 df                	jne    80103a20 <procdump+0x8d>
80103a41:	eb 84                	jmp    801039c7 <procdump+0x34>
  }
#ifdef CS333_P1
  cprintf("$ ");  // simulate shell prompt
80103a43:	83 ec 0c             	sub    $0xc,%esp
80103a46:	68 f3 6a 10 80       	push   $0x80106af3
80103a4b:	e8 bb cb ff ff       	call   8010060b <cprintf>
#endif // CS333_P1
}
80103a50:	83 c4 10             	add    $0x10,%esp
80103a53:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103a56:	5b                   	pop    %ebx
80103a57:	5e                   	pop    %esi
80103a58:	5d                   	pop    %ebp
80103a59:	c3                   	ret    

80103a5a <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80103a5a:	55                   	push   %ebp
80103a5b:	89 e5                	mov    %esp,%ebp
80103a5d:	53                   	push   %ebx
80103a5e:	83 ec 0c             	sub    $0xc,%esp
80103a61:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
80103a64:	68 8c 6b 10 80       	push   $0x80106b8c
80103a69:	8d 43 04             	lea    0x4(%ebx),%eax
80103a6c:	50                   	push   %eax
80103a6d:	e8 cc 00 00 00       	call   80103b3e <initlock>
  lk->name = name;
80103a72:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a75:	89 43 38             	mov    %eax,0x38(%ebx)
  lk->locked = 0;
80103a78:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103a7e:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
}
80103a85:	83 c4 10             	add    $0x10,%esp
80103a88:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a8b:	c9                   	leave  
80103a8c:	c3                   	ret    

80103a8d <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80103a8d:	55                   	push   %ebp
80103a8e:	89 e5                	mov    %esp,%ebp
80103a90:	56                   	push   %esi
80103a91:	53                   	push   %ebx
80103a92:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103a95:	8d 73 04             	lea    0x4(%ebx),%esi
80103a98:	83 ec 0c             	sub    $0xc,%esp
80103a9b:	56                   	push   %esi
80103a9c:	e8 d9 01 00 00       	call   80103c7a <acquire>
  while (lk->locked) {
80103aa1:	83 c4 10             	add    $0x10,%esp
80103aa4:	eb 0d                	jmp    80103ab3 <acquiresleep+0x26>
    sleep(lk, &lk->lk);
80103aa6:	83 ec 08             	sub    $0x8,%esp
80103aa9:	56                   	push   %esi
80103aaa:	53                   	push   %ebx
80103aab:	e8 5f fc ff ff       	call   8010370f <sleep>
80103ab0:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80103ab3:	83 3b 00             	cmpl   $0x0,(%ebx)
80103ab6:	75 ee                	jne    80103aa6 <acquiresleep+0x19>
  }
  lk->locked = 1;
80103ab8:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
80103abe:	e8 7e f7 ff ff       	call   80103241 <myproc>
80103ac3:	8b 40 14             	mov    0x14(%eax),%eax
80103ac6:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
80103ac9:	83 ec 0c             	sub    $0xc,%esp
80103acc:	56                   	push   %esi
80103acd:	e8 0d 02 00 00       	call   80103cdf <release>
}
80103ad2:	83 c4 10             	add    $0x10,%esp
80103ad5:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103ad8:	5b                   	pop    %ebx
80103ad9:	5e                   	pop    %esi
80103ada:	5d                   	pop    %ebp
80103adb:	c3                   	ret    

80103adc <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80103adc:	55                   	push   %ebp
80103add:	89 e5                	mov    %esp,%ebp
80103adf:	56                   	push   %esi
80103ae0:	53                   	push   %ebx
80103ae1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103ae4:	8d 73 04             	lea    0x4(%ebx),%esi
80103ae7:	83 ec 0c             	sub    $0xc,%esp
80103aea:	56                   	push   %esi
80103aeb:	e8 8a 01 00 00       	call   80103c7a <acquire>
  lk->locked = 0;
80103af0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103af6:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80103afd:	89 1c 24             	mov    %ebx,(%esp)
80103b00:	e8 6e fd ff ff       	call   80103873 <wakeup>
  release(&lk->lk);
80103b05:	89 34 24             	mov    %esi,(%esp)
80103b08:	e8 d2 01 00 00       	call   80103cdf <release>
}
80103b0d:	83 c4 10             	add    $0x10,%esp
80103b10:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103b13:	5b                   	pop    %ebx
80103b14:	5e                   	pop    %esi
80103b15:	5d                   	pop    %ebp
80103b16:	c3                   	ret    

80103b17 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80103b17:	55                   	push   %ebp
80103b18:	89 e5                	mov    %esp,%ebp
80103b1a:	56                   	push   %esi
80103b1b:	53                   	push   %ebx
80103b1c:	8b 75 08             	mov    0x8(%ebp),%esi
  int r;
  
  acquire(&lk->lk);
80103b1f:	8d 5e 04             	lea    0x4(%esi),%ebx
80103b22:	83 ec 0c             	sub    $0xc,%esp
80103b25:	53                   	push   %ebx
80103b26:	e8 4f 01 00 00       	call   80103c7a <acquire>
  r = lk->locked;
80103b2b:	8b 36                	mov    (%esi),%esi
  release(&lk->lk);
80103b2d:	89 1c 24             	mov    %ebx,(%esp)
80103b30:	e8 aa 01 00 00       	call   80103cdf <release>
  return r;
}
80103b35:	89 f0                	mov    %esi,%eax
80103b37:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103b3a:	5b                   	pop    %ebx
80103b3b:	5e                   	pop    %esi
80103b3c:	5d                   	pop    %ebp
80103b3d:	c3                   	ret    

80103b3e <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80103b3e:	55                   	push   %ebp
80103b3f:	89 e5                	mov    %esp,%ebp
80103b41:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80103b44:	8b 55 0c             	mov    0xc(%ebp),%edx
80103b47:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80103b4a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80103b50:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80103b57:	5d                   	pop    %ebp
80103b58:	c3                   	ret    

80103b59 <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80103b59:	55                   	push   %ebp
80103b5a:	89 e5                	mov    %esp,%ebp
80103b5c:	53                   	push   %ebx
80103b5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80103b60:	8b 45 08             	mov    0x8(%ebp),%eax
80103b63:	8d 50 f8             	lea    -0x8(%eax),%edx
  for(i = 0; i < 10; i++){
80103b66:	b8 00 00 00 00       	mov    $0x0,%eax
80103b6b:	83 f8 09             	cmp    $0x9,%eax
80103b6e:	7f 25                	jg     80103b95 <getcallerpcs+0x3c>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80103b70:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
80103b76:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80103b7c:	77 17                	ja     80103b95 <getcallerpcs+0x3c>
      break;
    pcs[i] = ebp[1];     // saved %eip
80103b7e:	8b 5a 04             	mov    0x4(%edx),%ebx
80103b81:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
    ebp = (uint*)ebp[0]; // saved %ebp
80103b84:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
80103b86:	83 c0 01             	add    $0x1,%eax
80103b89:	eb e0                	jmp    80103b6b <getcallerpcs+0x12>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
80103b8b:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
  for(; i < 10; i++)
80103b92:	83 c0 01             	add    $0x1,%eax
80103b95:	83 f8 09             	cmp    $0x9,%eax
80103b98:	7e f1                	jle    80103b8b <getcallerpcs+0x32>
}
80103b9a:	5b                   	pop    %ebx
80103b9b:	5d                   	pop    %ebp
80103b9c:	c3                   	ret    

80103b9d <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80103b9d:	55                   	push   %ebp
80103b9e:	89 e5                	mov    %esp,%ebp
80103ba0:	53                   	push   %ebx
80103ba1:	83 ec 04             	sub    $0x4,%esp
80103ba4:	9c                   	pushf  
80103ba5:	5b                   	pop    %ebx
  asm volatile("cli");
80103ba6:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
80103ba7:	e8 1e f6 ff ff       	call   801031ca <mycpu>
80103bac:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103bb3:	74 12                	je     80103bc7 <pushcli+0x2a>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
80103bb5:	e8 10 f6 ff ff       	call   801031ca <mycpu>
80103bba:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
80103bc1:	83 c4 04             	add    $0x4,%esp
80103bc4:	5b                   	pop    %ebx
80103bc5:	5d                   	pop    %ebp
80103bc6:	c3                   	ret    
    mycpu()->intena = eflags & FL_IF;
80103bc7:	e8 fe f5 ff ff       	call   801031ca <mycpu>
80103bcc:	81 e3 00 02 00 00    	and    $0x200,%ebx
80103bd2:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
80103bd8:	eb db                	jmp    80103bb5 <pushcli+0x18>

80103bda <popcli>:

void
popcli(void)
{
80103bda:	55                   	push   %ebp
80103bdb:	89 e5                	mov    %esp,%ebp
80103bdd:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103be0:	9c                   	pushf  
80103be1:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103be2:	f6 c4 02             	test   $0x2,%ah
80103be5:	75 28                	jne    80103c0f <popcli+0x35>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
80103be7:	e8 de f5 ff ff       	call   801031ca <mycpu>
80103bec:	8b 88 a4 00 00 00    	mov    0xa4(%eax),%ecx
80103bf2:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103bf5:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80103bfb:	85 d2                	test   %edx,%edx
80103bfd:	78 1d                	js     80103c1c <popcli+0x42>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103bff:	e8 c6 f5 ff ff       	call   801031ca <mycpu>
80103c04:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103c0b:	74 1c                	je     80103c29 <popcli+0x4f>
    sti();
}
80103c0d:	c9                   	leave  
80103c0e:	c3                   	ret    
    panic("popcli - interruptible");
80103c0f:	83 ec 0c             	sub    $0xc,%esp
80103c12:	68 97 6b 10 80       	push   $0x80106b97
80103c17:	e8 2c c7 ff ff       	call   80100348 <panic>
    panic("popcli");
80103c1c:	83 ec 0c             	sub    $0xc,%esp
80103c1f:	68 ae 6b 10 80       	push   $0x80106bae
80103c24:	e8 1f c7 ff ff       	call   80100348 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103c29:	e8 9c f5 ff ff       	call   801031ca <mycpu>
80103c2e:	83 b8 a8 00 00 00 00 	cmpl   $0x0,0xa8(%eax)
80103c35:	74 d6                	je     80103c0d <popcli+0x33>
  asm volatile("sti");
80103c37:	fb                   	sti    
}
80103c38:	eb d3                	jmp    80103c0d <popcli+0x33>

80103c3a <holding>:
{
80103c3a:	55                   	push   %ebp
80103c3b:	89 e5                	mov    %esp,%ebp
80103c3d:	53                   	push   %ebx
80103c3e:	83 ec 04             	sub    $0x4,%esp
80103c41:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
80103c44:	e8 54 ff ff ff       	call   80103b9d <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80103c49:	83 3b 00             	cmpl   $0x0,(%ebx)
80103c4c:	75 12                	jne    80103c60 <holding+0x26>
80103c4e:	bb 00 00 00 00       	mov    $0x0,%ebx
  popcli();
80103c53:	e8 82 ff ff ff       	call   80103bda <popcli>
}
80103c58:	89 d8                	mov    %ebx,%eax
80103c5a:	83 c4 04             	add    $0x4,%esp
80103c5d:	5b                   	pop    %ebx
80103c5e:	5d                   	pop    %ebp
80103c5f:	c3                   	ret    
  r = lock->locked && lock->cpu == mycpu();
80103c60:	8b 5b 08             	mov    0x8(%ebx),%ebx
80103c63:	e8 62 f5 ff ff       	call   801031ca <mycpu>
80103c68:	39 c3                	cmp    %eax,%ebx
80103c6a:	74 07                	je     80103c73 <holding+0x39>
80103c6c:	bb 00 00 00 00       	mov    $0x0,%ebx
80103c71:	eb e0                	jmp    80103c53 <holding+0x19>
80103c73:	bb 01 00 00 00       	mov    $0x1,%ebx
80103c78:	eb d9                	jmp    80103c53 <holding+0x19>

80103c7a <acquire>:
{
80103c7a:	55                   	push   %ebp
80103c7b:	89 e5                	mov    %esp,%ebp
80103c7d:	53                   	push   %ebx
80103c7e:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80103c81:	e8 17 ff ff ff       	call   80103b9d <pushcli>
  if(holding(lk))
80103c86:	83 ec 0c             	sub    $0xc,%esp
80103c89:	ff 75 08             	pushl  0x8(%ebp)
80103c8c:	e8 a9 ff ff ff       	call   80103c3a <holding>
80103c91:	83 c4 10             	add    $0x10,%esp
80103c94:	85 c0                	test   %eax,%eax
80103c96:	75 3a                	jne    80103cd2 <acquire+0x58>
  while(xchg(&lk->locked, 1) != 0)
80103c98:	8b 55 08             	mov    0x8(%ebp),%edx
  asm volatile("lock; xchgl %0, %1" :
80103c9b:	b8 01 00 00 00       	mov    $0x1,%eax
80103ca0:	f0 87 02             	lock xchg %eax,(%edx)
80103ca3:	85 c0                	test   %eax,%eax
80103ca5:	75 f1                	jne    80103c98 <acquire+0x1e>
  __sync_synchronize();
80103ca7:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
80103cac:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103caf:	e8 16 f5 ff ff       	call   801031ca <mycpu>
80103cb4:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80103cb7:	8b 45 08             	mov    0x8(%ebp),%eax
80103cba:	83 c0 0c             	add    $0xc,%eax
80103cbd:	83 ec 08             	sub    $0x8,%esp
80103cc0:	50                   	push   %eax
80103cc1:	8d 45 08             	lea    0x8(%ebp),%eax
80103cc4:	50                   	push   %eax
80103cc5:	e8 8f fe ff ff       	call   80103b59 <getcallerpcs>
}
80103cca:	83 c4 10             	add    $0x10,%esp
80103ccd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103cd0:	c9                   	leave  
80103cd1:	c3                   	ret    
    panic("acquire");
80103cd2:	83 ec 0c             	sub    $0xc,%esp
80103cd5:	68 b5 6b 10 80       	push   $0x80106bb5
80103cda:	e8 69 c6 ff ff       	call   80100348 <panic>

80103cdf <release>:
{
80103cdf:	55                   	push   %ebp
80103ce0:	89 e5                	mov    %esp,%ebp
80103ce2:	53                   	push   %ebx
80103ce3:	83 ec 10             	sub    $0x10,%esp
80103ce6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holding(lk))
80103ce9:	53                   	push   %ebx
80103cea:	e8 4b ff ff ff       	call   80103c3a <holding>
80103cef:	83 c4 10             	add    $0x10,%esp
80103cf2:	85 c0                	test   %eax,%eax
80103cf4:	74 23                	je     80103d19 <release+0x3a>
  lk->pcs[0] = 0;
80103cf6:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80103cfd:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
80103d04:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80103d09:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  popcli();
80103d0f:	e8 c6 fe ff ff       	call   80103bda <popcli>
}
80103d14:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103d17:	c9                   	leave  
80103d18:	c3                   	ret    
    panic("release");
80103d19:	83 ec 0c             	sub    $0xc,%esp
80103d1c:	68 bd 6b 10 80       	push   $0x80106bbd
80103d21:	e8 22 c6 ff ff       	call   80100348 <panic>

80103d26 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80103d26:	55                   	push   %ebp
80103d27:	89 e5                	mov    %esp,%ebp
80103d29:	57                   	push   %edi
80103d2a:	53                   	push   %ebx
80103d2b:	8b 55 08             	mov    0x8(%ebp),%edx
80103d2e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if ((int)dst%4 == 0 && n%4 == 0){
80103d31:	f6 c2 03             	test   $0x3,%dl
80103d34:	75 05                	jne    80103d3b <memset+0x15>
80103d36:	f6 c1 03             	test   $0x3,%cl
80103d39:	74 0e                	je     80103d49 <memset+0x23>
  asm volatile("cld; rep stosb" :
80103d3b:	89 d7                	mov    %edx,%edi
80103d3d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d40:	fc                   	cld    
80103d41:	f3 aa                	rep stos %al,%es:(%edi)
    c &= 0xFF;
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
  } else
    stosb(dst, c, n);
  return dst;
}
80103d43:	89 d0                	mov    %edx,%eax
80103d45:	5b                   	pop    %ebx
80103d46:	5f                   	pop    %edi
80103d47:	5d                   	pop    %ebp
80103d48:	c3                   	ret    
    c &= 0xFF;
80103d49:	0f b6 7d 0c          	movzbl 0xc(%ebp),%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80103d4d:	c1 e9 02             	shr    $0x2,%ecx
80103d50:	89 f8                	mov    %edi,%eax
80103d52:	c1 e0 18             	shl    $0x18,%eax
80103d55:	89 fb                	mov    %edi,%ebx
80103d57:	c1 e3 10             	shl    $0x10,%ebx
80103d5a:	09 d8                	or     %ebx,%eax
80103d5c:	89 fb                	mov    %edi,%ebx
80103d5e:	c1 e3 08             	shl    $0x8,%ebx
80103d61:	09 d8                	or     %ebx,%eax
80103d63:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
80103d65:	89 d7                	mov    %edx,%edi
80103d67:	fc                   	cld    
80103d68:	f3 ab                	rep stos %eax,%es:(%edi)
80103d6a:	eb d7                	jmp    80103d43 <memset+0x1d>

80103d6c <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80103d6c:	55                   	push   %ebp
80103d6d:	89 e5                	mov    %esp,%ebp
80103d6f:	56                   	push   %esi
80103d70:	53                   	push   %ebx
80103d71:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103d74:	8b 55 0c             	mov    0xc(%ebp),%edx
80103d77:	8b 45 10             	mov    0x10(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80103d7a:	8d 70 ff             	lea    -0x1(%eax),%esi
80103d7d:	85 c0                	test   %eax,%eax
80103d7f:	74 1c                	je     80103d9d <memcmp+0x31>
    if(*s1 != *s2)
80103d81:	0f b6 01             	movzbl (%ecx),%eax
80103d84:	0f b6 1a             	movzbl (%edx),%ebx
80103d87:	38 d8                	cmp    %bl,%al
80103d89:	75 0a                	jne    80103d95 <memcmp+0x29>
      return *s1 - *s2;
    s1++, s2++;
80103d8b:	83 c1 01             	add    $0x1,%ecx
80103d8e:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0){
80103d91:	89 f0                	mov    %esi,%eax
80103d93:	eb e5                	jmp    80103d7a <memcmp+0xe>
      return *s1 - *s2;
80103d95:	0f b6 c0             	movzbl %al,%eax
80103d98:	0f b6 db             	movzbl %bl,%ebx
80103d9b:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
80103d9d:	5b                   	pop    %ebx
80103d9e:	5e                   	pop    %esi
80103d9f:	5d                   	pop    %ebp
80103da0:	c3                   	ret    

80103da1 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80103da1:	55                   	push   %ebp
80103da2:	89 e5                	mov    %esp,%ebp
80103da4:	56                   	push   %esi
80103da5:	53                   	push   %ebx
80103da6:	8b 45 08             	mov    0x8(%ebp),%eax
80103da9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103dac:	8b 55 10             	mov    0x10(%ebp),%edx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80103daf:	39 c1                	cmp    %eax,%ecx
80103db1:	73 3a                	jae    80103ded <memmove+0x4c>
80103db3:	8d 1c 11             	lea    (%ecx,%edx,1),%ebx
80103db6:	39 c3                	cmp    %eax,%ebx
80103db8:	76 37                	jbe    80103df1 <memmove+0x50>
    s += n;
    d += n;
80103dba:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
    while(n-- > 0)
80103dbd:	eb 0d                	jmp    80103dcc <memmove+0x2b>
      *--d = *--s;
80103dbf:	83 eb 01             	sub    $0x1,%ebx
80103dc2:	83 e9 01             	sub    $0x1,%ecx
80103dc5:	0f b6 13             	movzbl (%ebx),%edx
80103dc8:	88 11                	mov    %dl,(%ecx)
    while(n-- > 0)
80103dca:	89 f2                	mov    %esi,%edx
80103dcc:	8d 72 ff             	lea    -0x1(%edx),%esi
80103dcf:	85 d2                	test   %edx,%edx
80103dd1:	75 ec                	jne    80103dbf <memmove+0x1e>
80103dd3:	eb 14                	jmp    80103de9 <memmove+0x48>
  } else
    while(n-- > 0)
      *d++ = *s++;
80103dd5:	0f b6 11             	movzbl (%ecx),%edx
80103dd8:	88 13                	mov    %dl,(%ebx)
80103dda:	8d 5b 01             	lea    0x1(%ebx),%ebx
80103ddd:	8d 49 01             	lea    0x1(%ecx),%ecx
    while(n-- > 0)
80103de0:	89 f2                	mov    %esi,%edx
80103de2:	8d 72 ff             	lea    -0x1(%edx),%esi
80103de5:	85 d2                	test   %edx,%edx
80103de7:	75 ec                	jne    80103dd5 <memmove+0x34>

  return dst;
}
80103de9:	5b                   	pop    %ebx
80103dea:	5e                   	pop    %esi
80103deb:	5d                   	pop    %ebp
80103dec:	c3                   	ret    
80103ded:	89 c3                	mov    %eax,%ebx
80103def:	eb f1                	jmp    80103de2 <memmove+0x41>
80103df1:	89 c3                	mov    %eax,%ebx
80103df3:	eb ed                	jmp    80103de2 <memmove+0x41>

80103df5 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80103df5:	55                   	push   %ebp
80103df6:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80103df8:	ff 75 10             	pushl  0x10(%ebp)
80103dfb:	ff 75 0c             	pushl  0xc(%ebp)
80103dfe:	ff 75 08             	pushl  0x8(%ebp)
80103e01:	e8 9b ff ff ff       	call   80103da1 <memmove>
}
80103e06:	c9                   	leave  
80103e07:	c3                   	ret    

80103e08 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80103e08:	55                   	push   %ebp
80103e09:	89 e5                	mov    %esp,%ebp
80103e0b:	53                   	push   %ebx
80103e0c:	8b 55 08             	mov    0x8(%ebp),%edx
80103e0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103e12:	8b 45 10             	mov    0x10(%ebp),%eax
  while(n > 0 && *p && *p == *q)
80103e15:	eb 09                	jmp    80103e20 <strncmp+0x18>
    n--, p++, q++;
80103e17:	83 e8 01             	sub    $0x1,%eax
80103e1a:	83 c2 01             	add    $0x1,%edx
80103e1d:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
80103e20:	85 c0                	test   %eax,%eax
80103e22:	74 0b                	je     80103e2f <strncmp+0x27>
80103e24:	0f b6 1a             	movzbl (%edx),%ebx
80103e27:	84 db                	test   %bl,%bl
80103e29:	74 04                	je     80103e2f <strncmp+0x27>
80103e2b:	3a 19                	cmp    (%ecx),%bl
80103e2d:	74 e8                	je     80103e17 <strncmp+0xf>
  if(n == 0)
80103e2f:	85 c0                	test   %eax,%eax
80103e31:	74 0b                	je     80103e3e <strncmp+0x36>
    return 0;
  return (uchar)*p - (uchar)*q;
80103e33:	0f b6 02             	movzbl (%edx),%eax
80103e36:	0f b6 11             	movzbl (%ecx),%edx
80103e39:	29 d0                	sub    %edx,%eax
}
80103e3b:	5b                   	pop    %ebx
80103e3c:	5d                   	pop    %ebp
80103e3d:	c3                   	ret    
    return 0;
80103e3e:	b8 00 00 00 00       	mov    $0x0,%eax
80103e43:	eb f6                	jmp    80103e3b <strncmp+0x33>

80103e45 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80103e45:	55                   	push   %ebp
80103e46:	89 e5                	mov    %esp,%ebp
80103e48:	57                   	push   %edi
80103e49:	56                   	push   %esi
80103e4a:	53                   	push   %ebx
80103e4b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103e4e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80103e51:	8b 45 08             	mov    0x8(%ebp),%eax
80103e54:	eb 04                	jmp    80103e5a <strncpy+0x15>
80103e56:	89 fb                	mov    %edi,%ebx
80103e58:	89 f0                	mov    %esi,%eax
80103e5a:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103e5d:	85 c9                	test   %ecx,%ecx
80103e5f:	7e 1d                	jle    80103e7e <strncpy+0x39>
80103e61:	8d 7b 01             	lea    0x1(%ebx),%edi
80103e64:	8d 70 01             	lea    0x1(%eax),%esi
80103e67:	0f b6 1b             	movzbl (%ebx),%ebx
80103e6a:	88 18                	mov    %bl,(%eax)
80103e6c:	89 d1                	mov    %edx,%ecx
80103e6e:	84 db                	test   %bl,%bl
80103e70:	75 e4                	jne    80103e56 <strncpy+0x11>
80103e72:	89 f0                	mov    %esi,%eax
80103e74:	eb 08                	jmp    80103e7e <strncpy+0x39>
    ;
  while(n-- > 0)
    *s++ = 0;
80103e76:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80103e79:	89 ca                	mov    %ecx,%edx
    *s++ = 0;
80103e7b:	8d 40 01             	lea    0x1(%eax),%eax
  while(n-- > 0)
80103e7e:	8d 4a ff             	lea    -0x1(%edx),%ecx
80103e81:	85 d2                	test   %edx,%edx
80103e83:	7f f1                	jg     80103e76 <strncpy+0x31>
  return os;
}
80103e85:	8b 45 08             	mov    0x8(%ebp),%eax
80103e88:	5b                   	pop    %ebx
80103e89:	5e                   	pop    %esi
80103e8a:	5f                   	pop    %edi
80103e8b:	5d                   	pop    %ebp
80103e8c:	c3                   	ret    

80103e8d <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80103e8d:	55                   	push   %ebp
80103e8e:	89 e5                	mov    %esp,%ebp
80103e90:	57                   	push   %edi
80103e91:	56                   	push   %esi
80103e92:	53                   	push   %ebx
80103e93:	8b 45 08             	mov    0x8(%ebp),%eax
80103e96:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103e99:	8b 55 10             	mov    0x10(%ebp),%edx
  char *os;

  os = s;
  if(n <= 0)
80103e9c:	85 d2                	test   %edx,%edx
80103e9e:	7e 23                	jle    80103ec3 <safestrcpy+0x36>
80103ea0:	89 c1                	mov    %eax,%ecx
80103ea2:	eb 04                	jmp    80103ea8 <safestrcpy+0x1b>
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80103ea4:	89 fb                	mov    %edi,%ebx
80103ea6:	89 f1                	mov    %esi,%ecx
80103ea8:	83 ea 01             	sub    $0x1,%edx
80103eab:	85 d2                	test   %edx,%edx
80103ead:	7e 11                	jle    80103ec0 <safestrcpy+0x33>
80103eaf:	8d 7b 01             	lea    0x1(%ebx),%edi
80103eb2:	8d 71 01             	lea    0x1(%ecx),%esi
80103eb5:	0f b6 1b             	movzbl (%ebx),%ebx
80103eb8:	88 19                	mov    %bl,(%ecx)
80103eba:	84 db                	test   %bl,%bl
80103ebc:	75 e6                	jne    80103ea4 <safestrcpy+0x17>
80103ebe:	89 f1                	mov    %esi,%ecx
    ;
  *s = 0;
80103ec0:	c6 01 00             	movb   $0x0,(%ecx)
  return os;
}
80103ec3:	5b                   	pop    %ebx
80103ec4:	5e                   	pop    %esi
80103ec5:	5f                   	pop    %edi
80103ec6:	5d                   	pop    %ebp
80103ec7:	c3                   	ret    

80103ec8 <strlen>:

int
strlen(const char *s)
{
80103ec8:	55                   	push   %ebp
80103ec9:	89 e5                	mov    %esp,%ebp
80103ecb:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
80103ece:	b8 00 00 00 00       	mov    $0x0,%eax
80103ed3:	eb 03                	jmp    80103ed8 <strlen+0x10>
80103ed5:	83 c0 01             	add    $0x1,%eax
80103ed8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80103edc:	75 f7                	jne    80103ed5 <strlen+0xd>
    ;
  return n;
}
80103ede:	5d                   	pop    %ebp
80103edf:	c3                   	ret    

80103ee0 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80103ee0:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80103ee4:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80103ee8:	55                   	push   %ebp
  pushl %ebx
80103ee9:	53                   	push   %ebx
  pushl %esi
80103eea:	56                   	push   %esi
  pushl %edi
80103eeb:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80103eec:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80103eee:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80103ef0:	5f                   	pop    %edi
  popl %esi
80103ef1:	5e                   	pop    %esi
  popl %ebx
80103ef2:	5b                   	pop    %ebx
  popl %ebp
80103ef3:	5d                   	pop    %ebp
  ret
80103ef4:	c3                   	ret    

80103ef5 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80103ef5:	55                   	push   %ebp
80103ef6:	89 e5                	mov    %esp,%ebp
80103ef8:	53                   	push   %ebx
80103ef9:	83 ec 04             	sub    $0x4,%esp
80103efc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
80103eff:	e8 3d f3 ff ff       	call   80103241 <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80103f04:	8b 40 04             	mov    0x4(%eax),%eax
80103f07:	39 d8                	cmp    %ebx,%eax
80103f09:	76 19                	jbe    80103f24 <fetchint+0x2f>
80103f0b:	8d 53 04             	lea    0x4(%ebx),%edx
80103f0e:	39 d0                	cmp    %edx,%eax
80103f10:	72 19                	jb     80103f2b <fetchint+0x36>
    return -1;
  *ip = *(int*)(addr);
80103f12:	8b 13                	mov    (%ebx),%edx
80103f14:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f17:	89 10                	mov    %edx,(%eax)
  return 0;
80103f19:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103f1e:	83 c4 04             	add    $0x4,%esp
80103f21:	5b                   	pop    %ebx
80103f22:	5d                   	pop    %ebp
80103f23:	c3                   	ret    
    return -1;
80103f24:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f29:	eb f3                	jmp    80103f1e <fetchint+0x29>
80103f2b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f30:	eb ec                	jmp    80103f1e <fetchint+0x29>

80103f32 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80103f32:	55                   	push   %ebp
80103f33:	89 e5                	mov    %esp,%ebp
80103f35:	53                   	push   %ebx
80103f36:	83 ec 04             	sub    $0x4,%esp
80103f39:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
80103f3c:	e8 00 f3 ff ff       	call   80103241 <myproc>

  if(addr >= curproc->sz)
80103f41:	39 58 04             	cmp    %ebx,0x4(%eax)
80103f44:	76 27                	jbe    80103f6d <fetchstr+0x3b>
    return -1;
  *pp = (char*)addr;
80103f46:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f49:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
80103f4b:	8b 50 04             	mov    0x4(%eax),%edx
  for(s = *pp; s < ep; s++){
80103f4e:	89 d8                	mov    %ebx,%eax
80103f50:	39 d0                	cmp    %edx,%eax
80103f52:	73 0e                	jae    80103f62 <fetchstr+0x30>
    if(*s == 0)
80103f54:	80 38 00             	cmpb   $0x0,(%eax)
80103f57:	74 05                	je     80103f5e <fetchstr+0x2c>
  for(s = *pp; s < ep; s++){
80103f59:	83 c0 01             	add    $0x1,%eax
80103f5c:	eb f2                	jmp    80103f50 <fetchstr+0x1e>
      return s - *pp;
80103f5e:	29 d8                	sub    %ebx,%eax
80103f60:	eb 05                	jmp    80103f67 <fetchstr+0x35>
  }
  return -1;
80103f62:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103f67:	83 c4 04             	add    $0x4,%esp
80103f6a:	5b                   	pop    %ebx
80103f6b:	5d                   	pop    %ebp
80103f6c:	c3                   	ret    
    return -1;
80103f6d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f72:	eb f3                	jmp    80103f67 <fetchstr+0x35>

80103f74 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80103f74:	55                   	push   %ebp
80103f75:	89 e5                	mov    %esp,%ebp
80103f77:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80103f7a:	e8 c2 f2 ff ff       	call   80103241 <myproc>
80103f7f:	8b 50 1c             	mov    0x1c(%eax),%edx
80103f82:	8b 45 08             	mov    0x8(%ebp),%eax
80103f85:	c1 e0 02             	shl    $0x2,%eax
80103f88:	03 42 44             	add    0x44(%edx),%eax
80103f8b:	83 ec 08             	sub    $0x8,%esp
80103f8e:	ff 75 0c             	pushl  0xc(%ebp)
80103f91:	83 c0 04             	add    $0x4,%eax
80103f94:	50                   	push   %eax
80103f95:	e8 5b ff ff ff       	call   80103ef5 <fetchint>
}
80103f9a:	c9                   	leave  
80103f9b:	c3                   	ret    

80103f9c <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80103f9c:	55                   	push   %ebp
80103f9d:	89 e5                	mov    %esp,%ebp
80103f9f:	56                   	push   %esi
80103fa0:	53                   	push   %ebx
80103fa1:	83 ec 10             	sub    $0x10,%esp
80103fa4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
80103fa7:	e8 95 f2 ff ff       	call   80103241 <myproc>
80103fac:	89 c6                	mov    %eax,%esi

  if(argint(n, &i) < 0)
80103fae:	83 ec 08             	sub    $0x8,%esp
80103fb1:	8d 45 f4             	lea    -0xc(%ebp),%eax
80103fb4:	50                   	push   %eax
80103fb5:	ff 75 08             	pushl  0x8(%ebp)
80103fb8:	e8 b7 ff ff ff       	call   80103f74 <argint>
80103fbd:	83 c4 10             	add    $0x10,%esp
80103fc0:	85 c0                	test   %eax,%eax
80103fc2:	78 25                	js     80103fe9 <argptr+0x4d>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80103fc4:	85 db                	test   %ebx,%ebx
80103fc6:	78 28                	js     80103ff0 <argptr+0x54>
80103fc8:	8b 56 04             	mov    0x4(%esi),%edx
80103fcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fce:	39 c2                	cmp    %eax,%edx
80103fd0:	76 25                	jbe    80103ff7 <argptr+0x5b>
80103fd2:	01 c3                	add    %eax,%ebx
80103fd4:	39 da                	cmp    %ebx,%edx
80103fd6:	72 26                	jb     80103ffe <argptr+0x62>
    return -1;
  *pp = (char*)i;
80103fd8:	8b 55 0c             	mov    0xc(%ebp),%edx
80103fdb:	89 02                	mov    %eax,(%edx)
  return 0;
80103fdd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103fe2:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103fe5:	5b                   	pop    %ebx
80103fe6:	5e                   	pop    %esi
80103fe7:	5d                   	pop    %ebp
80103fe8:	c3                   	ret    
    return -1;
80103fe9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103fee:	eb f2                	jmp    80103fe2 <argptr+0x46>
    return -1;
80103ff0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ff5:	eb eb                	jmp    80103fe2 <argptr+0x46>
80103ff7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ffc:	eb e4                	jmp    80103fe2 <argptr+0x46>
80103ffe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104003:	eb dd                	jmp    80103fe2 <argptr+0x46>

80104005 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104005:	55                   	push   %ebp
80104006:	89 e5                	mov    %esp,%ebp
80104008:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(n, &addr) < 0)
8010400b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010400e:	50                   	push   %eax
8010400f:	ff 75 08             	pushl  0x8(%ebp)
80104012:	e8 5d ff ff ff       	call   80103f74 <argint>
80104017:	83 c4 10             	add    $0x10,%esp
8010401a:	85 c0                	test   %eax,%eax
8010401c:	78 13                	js     80104031 <argstr+0x2c>
    return -1;
  return fetchstr(addr, pp);
8010401e:	83 ec 08             	sub    $0x8,%esp
80104021:	ff 75 0c             	pushl  0xc(%ebp)
80104024:	ff 75 f4             	pushl  -0xc(%ebp)
80104027:	e8 06 ff ff ff       	call   80103f32 <fetchstr>
8010402c:	83 c4 10             	add    $0x10,%esp
}
8010402f:	c9                   	leave  
80104030:	c3                   	ret    
    return -1;
80104031:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104036:	eb f7                	jmp    8010402f <argstr+0x2a>

80104038 <syscall>:
};
#endif // PRINT_SYSCALLS

void
syscall(void)
{
80104038:	55                   	push   %ebp
80104039:	89 e5                	mov    %esp,%ebp
8010403b:	53                   	push   %ebx
8010403c:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
8010403f:	e8 fd f1 ff ff       	call   80103241 <myproc>
80104044:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
80104046:	8b 40 1c             	mov    0x1c(%eax),%eax
80104049:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
8010404c:	8d 50 ff             	lea    -0x1(%eax),%edx
8010404f:	83 fa 16             	cmp    $0x16,%edx
80104052:	77 18                	ja     8010406c <syscall+0x34>
80104054:	8b 14 85 00 6c 10 80 	mov    -0x7fef9400(,%eax,4),%edx
8010405b:	85 d2                	test   %edx,%edx
8010405d:	74 0d                	je     8010406c <syscall+0x34>
    curproc->tf->eax = syscalls[num]();
8010405f:	ff d2                	call   *%edx
80104061:	8b 53 1c             	mov    0x1c(%ebx),%edx
80104064:	89 42 1c             	mov    %eax,0x1c(%edx)
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
  }
}
80104067:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010406a:	c9                   	leave  
8010406b:	c3                   	ret    
            curproc->pid, curproc->name, num);
8010406c:	8d 53 70             	lea    0x70(%ebx),%edx
    cprintf("%d %s: unknown sys call %d\n",
8010406f:	50                   	push   %eax
80104070:	52                   	push   %edx
80104071:	ff 73 14             	pushl  0x14(%ebx)
80104074:	68 c5 6b 10 80       	push   $0x80106bc5
80104079:	e8 8d c5 ff ff       	call   8010060b <cprintf>
    curproc->tf->eax = -1;
8010407e:	8b 43 1c             	mov    0x1c(%ebx),%eax
80104081:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
80104088:	83 c4 10             	add    $0x10,%esp
}
8010408b:	eb da                	jmp    80104067 <syscall+0x2f>

8010408d <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
8010408d:	55                   	push   %ebp
8010408e:	89 e5                	mov    %esp,%ebp
80104090:	56                   	push   %esi
80104091:	53                   	push   %ebx
80104092:	83 ec 18             	sub    $0x18,%esp
80104095:	89 d6                	mov    %edx,%esi
80104097:	89 cb                	mov    %ecx,%ebx
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80104099:	8d 55 f4             	lea    -0xc(%ebp),%edx
8010409c:	52                   	push   %edx
8010409d:	50                   	push   %eax
8010409e:	e8 d1 fe ff ff       	call   80103f74 <argint>
801040a3:	83 c4 10             	add    $0x10,%esp
801040a6:	85 c0                	test   %eax,%eax
801040a8:	78 2e                	js     801040d8 <argfd+0x4b>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801040aa:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801040ae:	77 2f                	ja     801040df <argfd+0x52>
801040b0:	e8 8c f1 ff ff       	call   80103241 <myproc>
801040b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040b8:	8b 44 90 2c          	mov    0x2c(%eax,%edx,4),%eax
801040bc:	85 c0                	test   %eax,%eax
801040be:	74 26                	je     801040e6 <argfd+0x59>
    return -1;
  if(pfd)
801040c0:	85 f6                	test   %esi,%esi
801040c2:	74 02                	je     801040c6 <argfd+0x39>
    *pfd = fd;
801040c4:	89 16                	mov    %edx,(%esi)
  if(pf)
801040c6:	85 db                	test   %ebx,%ebx
801040c8:	74 23                	je     801040ed <argfd+0x60>
    *pf = f;
801040ca:	89 03                	mov    %eax,(%ebx)
  return 0;
801040cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
801040d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
801040d4:	5b                   	pop    %ebx
801040d5:	5e                   	pop    %esi
801040d6:	5d                   	pop    %ebp
801040d7:	c3                   	ret    
    return -1;
801040d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040dd:	eb f2                	jmp    801040d1 <argfd+0x44>
    return -1;
801040df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040e4:	eb eb                	jmp    801040d1 <argfd+0x44>
801040e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040eb:	eb e4                	jmp    801040d1 <argfd+0x44>
  return 0;
801040ed:	b8 00 00 00 00       	mov    $0x0,%eax
801040f2:	eb dd                	jmp    801040d1 <argfd+0x44>

801040f4 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801040f4:	55                   	push   %ebp
801040f5:	89 e5                	mov    %esp,%ebp
801040f7:	53                   	push   %ebx
801040f8:	83 ec 04             	sub    $0x4,%esp
801040fb:	89 c3                	mov    %eax,%ebx
  int fd;
  struct proc *curproc = myproc();
801040fd:	e8 3f f1 ff ff       	call   80103241 <myproc>

  for(fd = 0; fd < NOFILE; fd++){
80104102:	ba 00 00 00 00       	mov    $0x0,%edx
80104107:	83 fa 0f             	cmp    $0xf,%edx
8010410a:	7f 18                	jg     80104124 <fdalloc+0x30>
    if(curproc->ofile[fd] == 0){
8010410c:	83 7c 90 2c 00       	cmpl   $0x0,0x2c(%eax,%edx,4)
80104111:	74 05                	je     80104118 <fdalloc+0x24>
  for(fd = 0; fd < NOFILE; fd++){
80104113:	83 c2 01             	add    $0x1,%edx
80104116:	eb ef                	jmp    80104107 <fdalloc+0x13>
      curproc->ofile[fd] = f;
80104118:	89 5c 90 2c          	mov    %ebx,0x2c(%eax,%edx,4)
      return fd;
    }
  }
  return -1;
}
8010411c:	89 d0                	mov    %edx,%eax
8010411e:	83 c4 04             	add    $0x4,%esp
80104121:	5b                   	pop    %ebx
80104122:	5d                   	pop    %ebp
80104123:	c3                   	ret    
  return -1;
80104124:	ba ff ff ff ff       	mov    $0xffffffff,%edx
80104129:	eb f1                	jmp    8010411c <fdalloc+0x28>

8010412b <isdirempty>:
}

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
8010412b:	55                   	push   %ebp
8010412c:	89 e5                	mov    %esp,%ebp
8010412e:	56                   	push   %esi
8010412f:	53                   	push   %ebx
80104130:	83 ec 10             	sub    $0x10,%esp
80104133:	89 c3                	mov    %eax,%ebx
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80104135:	b8 20 00 00 00       	mov    $0x20,%eax
8010413a:	89 c6                	mov    %eax,%esi
8010413c:	39 43 58             	cmp    %eax,0x58(%ebx)
8010413f:	76 2e                	jbe    8010416f <isdirempty+0x44>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80104141:	6a 10                	push   $0x10
80104143:	50                   	push   %eax
80104144:	8d 45 e8             	lea    -0x18(%ebp),%eax
80104147:	50                   	push   %eax
80104148:	53                   	push   %ebx
80104149:	e8 59 d6 ff ff       	call   801017a7 <readi>
8010414e:	83 c4 10             	add    $0x10,%esp
80104151:	83 f8 10             	cmp    $0x10,%eax
80104154:	75 0c                	jne    80104162 <isdirempty+0x37>
      panic("isdirempty: readi");
    if(de.inum != 0)
80104156:	66 83 7d e8 00       	cmpw   $0x0,-0x18(%ebp)
8010415b:	75 1e                	jne    8010417b <isdirempty+0x50>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010415d:	8d 46 10             	lea    0x10(%esi),%eax
80104160:	eb d8                	jmp    8010413a <isdirempty+0xf>
      panic("isdirempty: readi");
80104162:	83 ec 0c             	sub    $0xc,%esp
80104165:	68 60 6c 10 80       	push   $0x80106c60
8010416a:	e8 d9 c1 ff ff       	call   80100348 <panic>
      return 0;
  }
  return 1;
8010416f:	b8 01 00 00 00       	mov    $0x1,%eax
}
80104174:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104177:	5b                   	pop    %ebx
80104178:	5e                   	pop    %esi
80104179:	5d                   	pop    %ebp
8010417a:	c3                   	ret    
      return 0;
8010417b:	b8 00 00 00 00       	mov    $0x0,%eax
80104180:	eb f2                	jmp    80104174 <isdirempty+0x49>

80104182 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
80104182:	55                   	push   %ebp
80104183:	89 e5                	mov    %esp,%ebp
80104185:	57                   	push   %edi
80104186:	56                   	push   %esi
80104187:	53                   	push   %ebx
80104188:	83 ec 44             	sub    $0x44,%esp
8010418b:	89 55 c4             	mov    %edx,-0x3c(%ebp)
8010418e:	89 4d c0             	mov    %ecx,-0x40(%ebp)
80104191:	8b 7d 08             	mov    0x8(%ebp),%edi
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80104194:	8d 55 d6             	lea    -0x2a(%ebp),%edx
80104197:	52                   	push   %edx
80104198:	50                   	push   %eax
80104199:	e8 8f da ff ff       	call   80101c2d <nameiparent>
8010419e:	89 c6                	mov    %eax,%esi
801041a0:	83 c4 10             	add    $0x10,%esp
801041a3:	85 c0                	test   %eax,%eax
801041a5:	0f 84 3a 01 00 00    	je     801042e5 <create+0x163>
    return 0;
  ilock(dp);
801041ab:	83 ec 0c             	sub    $0xc,%esp
801041ae:	50                   	push   %eax
801041af:	e8 01 d4 ff ff       	call   801015b5 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
801041b4:	83 c4 0c             	add    $0xc,%esp
801041b7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801041ba:	50                   	push   %eax
801041bb:	8d 45 d6             	lea    -0x2a(%ebp),%eax
801041be:	50                   	push   %eax
801041bf:	56                   	push   %esi
801041c0:	e8 1f d8 ff ff       	call   801019e4 <dirlookup>
801041c5:	89 c3                	mov    %eax,%ebx
801041c7:	83 c4 10             	add    $0x10,%esp
801041ca:	85 c0                	test   %eax,%eax
801041cc:	74 3f                	je     8010420d <create+0x8b>
    iunlockput(dp);
801041ce:	83 ec 0c             	sub    $0xc,%esp
801041d1:	56                   	push   %esi
801041d2:	e8 85 d5 ff ff       	call   8010175c <iunlockput>
    ilock(ip);
801041d7:	89 1c 24             	mov    %ebx,(%esp)
801041da:	e8 d6 d3 ff ff       	call   801015b5 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
801041df:	83 c4 10             	add    $0x10,%esp
801041e2:	66 83 7d c4 02       	cmpw   $0x2,-0x3c(%ebp)
801041e7:	75 11                	jne    801041fa <create+0x78>
801041e9:	66 83 7b 50 02       	cmpw   $0x2,0x50(%ebx)
801041ee:	75 0a                	jne    801041fa <create+0x78>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
801041f0:	89 d8                	mov    %ebx,%eax
801041f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801041f5:	5b                   	pop    %ebx
801041f6:	5e                   	pop    %esi
801041f7:	5f                   	pop    %edi
801041f8:	5d                   	pop    %ebp
801041f9:	c3                   	ret    
    iunlockput(ip);
801041fa:	83 ec 0c             	sub    $0xc,%esp
801041fd:	53                   	push   %ebx
801041fe:	e8 59 d5 ff ff       	call   8010175c <iunlockput>
    return 0;
80104203:	83 c4 10             	add    $0x10,%esp
80104206:	bb 00 00 00 00       	mov    $0x0,%ebx
8010420b:	eb e3                	jmp    801041f0 <create+0x6e>
  if((ip = ialloc(dp->dev, type)) == 0)
8010420d:	0f bf 45 c4          	movswl -0x3c(%ebp),%eax
80104211:	83 ec 08             	sub    $0x8,%esp
80104214:	50                   	push   %eax
80104215:	ff 36                	pushl  (%esi)
80104217:	e8 96 d1 ff ff       	call   801013b2 <ialloc>
8010421c:	89 c3                	mov    %eax,%ebx
8010421e:	83 c4 10             	add    $0x10,%esp
80104221:	85 c0                	test   %eax,%eax
80104223:	74 55                	je     8010427a <create+0xf8>
  ilock(ip);
80104225:	83 ec 0c             	sub    $0xc,%esp
80104228:	50                   	push   %eax
80104229:	e8 87 d3 ff ff       	call   801015b5 <ilock>
  ip->major = major;
8010422e:	0f b7 45 c0          	movzwl -0x40(%ebp),%eax
80104232:	66 89 43 52          	mov    %ax,0x52(%ebx)
  ip->minor = minor;
80104236:	66 89 7b 54          	mov    %di,0x54(%ebx)
  ip->nlink = 1;
8010423a:	66 c7 43 56 01 00    	movw   $0x1,0x56(%ebx)
  iupdate(ip);
80104240:	89 1c 24             	mov    %ebx,(%esp)
80104243:	e8 0c d2 ff ff       	call   80101454 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
80104248:	83 c4 10             	add    $0x10,%esp
8010424b:	66 83 7d c4 01       	cmpw   $0x1,-0x3c(%ebp)
80104250:	74 35                	je     80104287 <create+0x105>
  if(dirlink(dp, name, ip->inum) < 0)
80104252:	83 ec 04             	sub    $0x4,%esp
80104255:	ff 73 04             	pushl  0x4(%ebx)
80104258:	8d 45 d6             	lea    -0x2a(%ebp),%eax
8010425b:	50                   	push   %eax
8010425c:	56                   	push   %esi
8010425d:	e8 02 d9 ff ff       	call   80101b64 <dirlink>
80104262:	83 c4 10             	add    $0x10,%esp
80104265:	85 c0                	test   %eax,%eax
80104267:	78 6f                	js     801042d8 <create+0x156>
  iunlockput(dp);
80104269:	83 ec 0c             	sub    $0xc,%esp
8010426c:	56                   	push   %esi
8010426d:	e8 ea d4 ff ff       	call   8010175c <iunlockput>
  return ip;
80104272:	83 c4 10             	add    $0x10,%esp
80104275:	e9 76 ff ff ff       	jmp    801041f0 <create+0x6e>
    panic("create: ialloc");
8010427a:	83 ec 0c             	sub    $0xc,%esp
8010427d:	68 72 6c 10 80       	push   $0x80106c72
80104282:	e8 c1 c0 ff ff       	call   80100348 <panic>
    dp->nlink++;  // for ".."
80104287:	0f b7 46 56          	movzwl 0x56(%esi),%eax
8010428b:	83 c0 01             	add    $0x1,%eax
8010428e:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
80104292:	83 ec 0c             	sub    $0xc,%esp
80104295:	56                   	push   %esi
80104296:	e8 b9 d1 ff ff       	call   80101454 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
8010429b:	83 c4 0c             	add    $0xc,%esp
8010429e:	ff 73 04             	pushl  0x4(%ebx)
801042a1:	68 82 6c 10 80       	push   $0x80106c82
801042a6:	53                   	push   %ebx
801042a7:	e8 b8 d8 ff ff       	call   80101b64 <dirlink>
801042ac:	83 c4 10             	add    $0x10,%esp
801042af:	85 c0                	test   %eax,%eax
801042b1:	78 18                	js     801042cb <create+0x149>
801042b3:	83 ec 04             	sub    $0x4,%esp
801042b6:	ff 76 04             	pushl  0x4(%esi)
801042b9:	68 81 6c 10 80       	push   $0x80106c81
801042be:	53                   	push   %ebx
801042bf:	e8 a0 d8 ff ff       	call   80101b64 <dirlink>
801042c4:	83 c4 10             	add    $0x10,%esp
801042c7:	85 c0                	test   %eax,%eax
801042c9:	79 87                	jns    80104252 <create+0xd0>
      panic("create dots");
801042cb:	83 ec 0c             	sub    $0xc,%esp
801042ce:	68 84 6c 10 80       	push   $0x80106c84
801042d3:	e8 70 c0 ff ff       	call   80100348 <panic>
    panic("create: dirlink");
801042d8:	83 ec 0c             	sub    $0xc,%esp
801042db:	68 90 6c 10 80       	push   $0x80106c90
801042e0:	e8 63 c0 ff ff       	call   80100348 <panic>
    return 0;
801042e5:	89 c3                	mov    %eax,%ebx
801042e7:	e9 04 ff ff ff       	jmp    801041f0 <create+0x6e>

801042ec <sys_dup>:
{
801042ec:	55                   	push   %ebp
801042ed:	89 e5                	mov    %esp,%ebp
801042ef:	53                   	push   %ebx
801042f0:	83 ec 14             	sub    $0x14,%esp
  if(argfd(0, 0, &f) < 0)
801042f3:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801042f6:	ba 00 00 00 00       	mov    $0x0,%edx
801042fb:	b8 00 00 00 00       	mov    $0x0,%eax
80104300:	e8 88 fd ff ff       	call   8010408d <argfd>
80104305:	85 c0                	test   %eax,%eax
80104307:	78 23                	js     8010432c <sys_dup+0x40>
  if((fd=fdalloc(f)) < 0)
80104309:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010430c:	e8 e3 fd ff ff       	call   801040f4 <fdalloc>
80104311:	89 c3                	mov    %eax,%ebx
80104313:	85 c0                	test   %eax,%eax
80104315:	78 1c                	js     80104333 <sys_dup+0x47>
  filedup(f);
80104317:	83 ec 0c             	sub    $0xc,%esp
8010431a:	ff 75 f4             	pushl  -0xc(%ebp)
8010431d:	e8 a0 c9 ff ff       	call   80100cc2 <filedup>
  return fd;
80104322:	83 c4 10             	add    $0x10,%esp
}
80104325:	89 d8                	mov    %ebx,%eax
80104327:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010432a:	c9                   	leave  
8010432b:	c3                   	ret    
    return -1;
8010432c:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104331:	eb f2                	jmp    80104325 <sys_dup+0x39>
    return -1;
80104333:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104338:	eb eb                	jmp    80104325 <sys_dup+0x39>

8010433a <sys_read>:
{
8010433a:	55                   	push   %ebp
8010433b:	89 e5                	mov    %esp,%ebp
8010433d:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104340:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104343:	ba 00 00 00 00       	mov    $0x0,%edx
80104348:	b8 00 00 00 00       	mov    $0x0,%eax
8010434d:	e8 3b fd ff ff       	call   8010408d <argfd>
80104352:	85 c0                	test   %eax,%eax
80104354:	78 43                	js     80104399 <sys_read+0x5f>
80104356:	83 ec 08             	sub    $0x8,%esp
80104359:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010435c:	50                   	push   %eax
8010435d:	6a 02                	push   $0x2
8010435f:	e8 10 fc ff ff       	call   80103f74 <argint>
80104364:	83 c4 10             	add    $0x10,%esp
80104367:	85 c0                	test   %eax,%eax
80104369:	78 35                	js     801043a0 <sys_read+0x66>
8010436b:	83 ec 04             	sub    $0x4,%esp
8010436e:	ff 75 f0             	pushl  -0x10(%ebp)
80104371:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104374:	50                   	push   %eax
80104375:	6a 01                	push   $0x1
80104377:	e8 20 fc ff ff       	call   80103f9c <argptr>
8010437c:	83 c4 10             	add    $0x10,%esp
8010437f:	85 c0                	test   %eax,%eax
80104381:	78 24                	js     801043a7 <sys_read+0x6d>
  return fileread(f, p, n);
80104383:	83 ec 04             	sub    $0x4,%esp
80104386:	ff 75 f0             	pushl  -0x10(%ebp)
80104389:	ff 75 ec             	pushl  -0x14(%ebp)
8010438c:	ff 75 f4             	pushl  -0xc(%ebp)
8010438f:	e8 77 ca ff ff       	call   80100e0b <fileread>
80104394:	83 c4 10             	add    $0x10,%esp
}
80104397:	c9                   	leave  
80104398:	c3                   	ret    
    return -1;
80104399:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010439e:	eb f7                	jmp    80104397 <sys_read+0x5d>
801043a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043a5:	eb f0                	jmp    80104397 <sys_read+0x5d>
801043a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043ac:	eb e9                	jmp    80104397 <sys_read+0x5d>

801043ae <sys_write>:
{
801043ae:	55                   	push   %ebp
801043af:	89 e5                	mov    %esp,%ebp
801043b1:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801043b4:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801043b7:	ba 00 00 00 00       	mov    $0x0,%edx
801043bc:	b8 00 00 00 00       	mov    $0x0,%eax
801043c1:	e8 c7 fc ff ff       	call   8010408d <argfd>
801043c6:	85 c0                	test   %eax,%eax
801043c8:	78 43                	js     8010440d <sys_write+0x5f>
801043ca:	83 ec 08             	sub    $0x8,%esp
801043cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
801043d0:	50                   	push   %eax
801043d1:	6a 02                	push   $0x2
801043d3:	e8 9c fb ff ff       	call   80103f74 <argint>
801043d8:	83 c4 10             	add    $0x10,%esp
801043db:	85 c0                	test   %eax,%eax
801043dd:	78 35                	js     80104414 <sys_write+0x66>
801043df:	83 ec 04             	sub    $0x4,%esp
801043e2:	ff 75 f0             	pushl  -0x10(%ebp)
801043e5:	8d 45 ec             	lea    -0x14(%ebp),%eax
801043e8:	50                   	push   %eax
801043e9:	6a 01                	push   $0x1
801043eb:	e8 ac fb ff ff       	call   80103f9c <argptr>
801043f0:	83 c4 10             	add    $0x10,%esp
801043f3:	85 c0                	test   %eax,%eax
801043f5:	78 24                	js     8010441b <sys_write+0x6d>
  return filewrite(f, p, n);
801043f7:	83 ec 04             	sub    $0x4,%esp
801043fa:	ff 75 f0             	pushl  -0x10(%ebp)
801043fd:	ff 75 ec             	pushl  -0x14(%ebp)
80104400:	ff 75 f4             	pushl  -0xc(%ebp)
80104403:	e8 88 ca ff ff       	call   80100e90 <filewrite>
80104408:	83 c4 10             	add    $0x10,%esp
}
8010440b:	c9                   	leave  
8010440c:	c3                   	ret    
    return -1;
8010440d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104412:	eb f7                	jmp    8010440b <sys_write+0x5d>
80104414:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104419:	eb f0                	jmp    8010440b <sys_write+0x5d>
8010441b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104420:	eb e9                	jmp    8010440b <sys_write+0x5d>

80104422 <sys_close>:
{
80104422:	55                   	push   %ebp
80104423:	89 e5                	mov    %esp,%ebp
80104425:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
80104428:	8d 4d f0             	lea    -0x10(%ebp),%ecx
8010442b:	8d 55 f4             	lea    -0xc(%ebp),%edx
8010442e:	b8 00 00 00 00       	mov    $0x0,%eax
80104433:	e8 55 fc ff ff       	call   8010408d <argfd>
80104438:	85 c0                	test   %eax,%eax
8010443a:	78 25                	js     80104461 <sys_close+0x3f>
  myproc()->ofile[fd] = 0;
8010443c:	e8 00 ee ff ff       	call   80103241 <myproc>
80104441:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104444:	c7 44 90 2c 00 00 00 	movl   $0x0,0x2c(%eax,%edx,4)
8010444b:	00 
  fileclose(f);
8010444c:	83 ec 0c             	sub    $0xc,%esp
8010444f:	ff 75 f0             	pushl  -0x10(%ebp)
80104452:	e8 b0 c8 ff ff       	call   80100d07 <fileclose>
  return 0;
80104457:	83 c4 10             	add    $0x10,%esp
8010445a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010445f:	c9                   	leave  
80104460:	c3                   	ret    
    return -1;
80104461:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104466:	eb f7                	jmp    8010445f <sys_close+0x3d>

80104468 <sys_fstat>:
{
80104468:	55                   	push   %ebp
80104469:	89 e5                	mov    %esp,%ebp
8010446b:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010446e:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104471:	ba 00 00 00 00       	mov    $0x0,%edx
80104476:	b8 00 00 00 00       	mov    $0x0,%eax
8010447b:	e8 0d fc ff ff       	call   8010408d <argfd>
80104480:	85 c0                	test   %eax,%eax
80104482:	78 2a                	js     801044ae <sys_fstat+0x46>
80104484:	83 ec 04             	sub    $0x4,%esp
80104487:	6a 14                	push   $0x14
80104489:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010448c:	50                   	push   %eax
8010448d:	6a 01                	push   $0x1
8010448f:	e8 08 fb ff ff       	call   80103f9c <argptr>
80104494:	83 c4 10             	add    $0x10,%esp
80104497:	85 c0                	test   %eax,%eax
80104499:	78 1a                	js     801044b5 <sys_fstat+0x4d>
  return filestat(f, st);
8010449b:	83 ec 08             	sub    $0x8,%esp
8010449e:	ff 75 f0             	pushl  -0x10(%ebp)
801044a1:	ff 75 f4             	pushl  -0xc(%ebp)
801044a4:	e8 1b c9 ff ff       	call   80100dc4 <filestat>
801044a9:	83 c4 10             	add    $0x10,%esp
}
801044ac:	c9                   	leave  
801044ad:	c3                   	ret    
    return -1;
801044ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044b3:	eb f7                	jmp    801044ac <sys_fstat+0x44>
801044b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044ba:	eb f0                	jmp    801044ac <sys_fstat+0x44>

801044bc <sys_link>:
{
801044bc:	55                   	push   %ebp
801044bd:	89 e5                	mov    %esp,%ebp
801044bf:	56                   	push   %esi
801044c0:	53                   	push   %ebx
801044c1:	83 ec 28             	sub    $0x28,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801044c4:	8d 45 e0             	lea    -0x20(%ebp),%eax
801044c7:	50                   	push   %eax
801044c8:	6a 00                	push   $0x0
801044ca:	e8 36 fb ff ff       	call   80104005 <argstr>
801044cf:	83 c4 10             	add    $0x10,%esp
801044d2:	85 c0                	test   %eax,%eax
801044d4:	0f 88 32 01 00 00    	js     8010460c <sys_link+0x150>
801044da:	83 ec 08             	sub    $0x8,%esp
801044dd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801044e0:	50                   	push   %eax
801044e1:	6a 01                	push   $0x1
801044e3:	e8 1d fb ff ff       	call   80104005 <argstr>
801044e8:	83 c4 10             	add    $0x10,%esp
801044eb:	85 c0                	test   %eax,%eax
801044ed:	0f 88 20 01 00 00    	js     80104613 <sys_link+0x157>
  begin_op();
801044f3:	e8 ea e2 ff ff       	call   801027e2 <begin_op>
  if((ip = namei(old)) == 0){
801044f8:	83 ec 0c             	sub    $0xc,%esp
801044fb:	ff 75 e0             	pushl  -0x20(%ebp)
801044fe:	e8 12 d7 ff ff       	call   80101c15 <namei>
80104503:	89 c3                	mov    %eax,%ebx
80104505:	83 c4 10             	add    $0x10,%esp
80104508:	85 c0                	test   %eax,%eax
8010450a:	0f 84 99 00 00 00    	je     801045a9 <sys_link+0xed>
  ilock(ip);
80104510:	83 ec 0c             	sub    $0xc,%esp
80104513:	50                   	push   %eax
80104514:	e8 9c d0 ff ff       	call   801015b5 <ilock>
  if(ip->type == T_DIR){
80104519:	83 c4 10             	add    $0x10,%esp
8010451c:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104521:	0f 84 8e 00 00 00    	je     801045b5 <sys_link+0xf9>
  ip->nlink++;
80104527:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
8010452b:	83 c0 01             	add    $0x1,%eax
8010452e:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104532:	83 ec 0c             	sub    $0xc,%esp
80104535:	53                   	push   %ebx
80104536:	e8 19 cf ff ff       	call   80101454 <iupdate>
  iunlock(ip);
8010453b:	89 1c 24             	mov    %ebx,(%esp)
8010453e:	e8 34 d1 ff ff       	call   80101677 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
80104543:	83 c4 08             	add    $0x8,%esp
80104546:	8d 45 ea             	lea    -0x16(%ebp),%eax
80104549:	50                   	push   %eax
8010454a:	ff 75 e4             	pushl  -0x1c(%ebp)
8010454d:	e8 db d6 ff ff       	call   80101c2d <nameiparent>
80104552:	89 c6                	mov    %eax,%esi
80104554:	83 c4 10             	add    $0x10,%esp
80104557:	85 c0                	test   %eax,%eax
80104559:	74 7e                	je     801045d9 <sys_link+0x11d>
  ilock(dp);
8010455b:	83 ec 0c             	sub    $0xc,%esp
8010455e:	50                   	push   %eax
8010455f:	e8 51 d0 ff ff       	call   801015b5 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80104564:	83 c4 10             	add    $0x10,%esp
80104567:	8b 03                	mov    (%ebx),%eax
80104569:	39 06                	cmp    %eax,(%esi)
8010456b:	75 60                	jne    801045cd <sys_link+0x111>
8010456d:	83 ec 04             	sub    $0x4,%esp
80104570:	ff 73 04             	pushl  0x4(%ebx)
80104573:	8d 45 ea             	lea    -0x16(%ebp),%eax
80104576:	50                   	push   %eax
80104577:	56                   	push   %esi
80104578:	e8 e7 d5 ff ff       	call   80101b64 <dirlink>
8010457d:	83 c4 10             	add    $0x10,%esp
80104580:	85 c0                	test   %eax,%eax
80104582:	78 49                	js     801045cd <sys_link+0x111>
  iunlockput(dp);
80104584:	83 ec 0c             	sub    $0xc,%esp
80104587:	56                   	push   %esi
80104588:	e8 cf d1 ff ff       	call   8010175c <iunlockput>
  iput(ip);
8010458d:	89 1c 24             	mov    %ebx,(%esp)
80104590:	e8 27 d1 ff ff       	call   801016bc <iput>
  end_op();
80104595:	e8 c2 e2 ff ff       	call   8010285c <end_op>
  return 0;
8010459a:	83 c4 10             	add    $0x10,%esp
8010459d:	b8 00 00 00 00       	mov    $0x0,%eax
}
801045a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
801045a5:	5b                   	pop    %ebx
801045a6:	5e                   	pop    %esi
801045a7:	5d                   	pop    %ebp
801045a8:	c3                   	ret    
    end_op();
801045a9:	e8 ae e2 ff ff       	call   8010285c <end_op>
    return -1;
801045ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045b3:	eb ed                	jmp    801045a2 <sys_link+0xe6>
    iunlockput(ip);
801045b5:	83 ec 0c             	sub    $0xc,%esp
801045b8:	53                   	push   %ebx
801045b9:	e8 9e d1 ff ff       	call   8010175c <iunlockput>
    end_op();
801045be:	e8 99 e2 ff ff       	call   8010285c <end_op>
    return -1;
801045c3:	83 c4 10             	add    $0x10,%esp
801045c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045cb:	eb d5                	jmp    801045a2 <sys_link+0xe6>
    iunlockput(dp);
801045cd:	83 ec 0c             	sub    $0xc,%esp
801045d0:	56                   	push   %esi
801045d1:	e8 86 d1 ff ff       	call   8010175c <iunlockput>
    goto bad;
801045d6:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
801045d9:	83 ec 0c             	sub    $0xc,%esp
801045dc:	53                   	push   %ebx
801045dd:	e8 d3 cf ff ff       	call   801015b5 <ilock>
  ip->nlink--;
801045e2:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
801045e6:	83 e8 01             	sub    $0x1,%eax
801045e9:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801045ed:	89 1c 24             	mov    %ebx,(%esp)
801045f0:	e8 5f ce ff ff       	call   80101454 <iupdate>
  iunlockput(ip);
801045f5:	89 1c 24             	mov    %ebx,(%esp)
801045f8:	e8 5f d1 ff ff       	call   8010175c <iunlockput>
  end_op();
801045fd:	e8 5a e2 ff ff       	call   8010285c <end_op>
  return -1;
80104602:	83 c4 10             	add    $0x10,%esp
80104605:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010460a:	eb 96                	jmp    801045a2 <sys_link+0xe6>
    return -1;
8010460c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104611:	eb 8f                	jmp    801045a2 <sys_link+0xe6>
80104613:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104618:	eb 88                	jmp    801045a2 <sys_link+0xe6>

8010461a <sys_unlink>:
{
8010461a:	55                   	push   %ebp
8010461b:	89 e5                	mov    %esp,%ebp
8010461d:	57                   	push   %edi
8010461e:	56                   	push   %esi
8010461f:	53                   	push   %ebx
80104620:	83 ec 44             	sub    $0x44,%esp
  if(argstr(0, &path) < 0)
80104623:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104626:	50                   	push   %eax
80104627:	6a 00                	push   $0x0
80104629:	e8 d7 f9 ff ff       	call   80104005 <argstr>
8010462e:	83 c4 10             	add    $0x10,%esp
80104631:	85 c0                	test   %eax,%eax
80104633:	0f 88 83 01 00 00    	js     801047bc <sys_unlink+0x1a2>
  begin_op();
80104639:	e8 a4 e1 ff ff       	call   801027e2 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
8010463e:	83 ec 08             	sub    $0x8,%esp
80104641:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104644:	50                   	push   %eax
80104645:	ff 75 c4             	pushl  -0x3c(%ebp)
80104648:	e8 e0 d5 ff ff       	call   80101c2d <nameiparent>
8010464d:	89 c6                	mov    %eax,%esi
8010464f:	83 c4 10             	add    $0x10,%esp
80104652:	85 c0                	test   %eax,%eax
80104654:	0f 84 ed 00 00 00    	je     80104747 <sys_unlink+0x12d>
  ilock(dp);
8010465a:	83 ec 0c             	sub    $0xc,%esp
8010465d:	50                   	push   %eax
8010465e:	e8 52 cf ff ff       	call   801015b5 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80104663:	83 c4 08             	add    $0x8,%esp
80104666:	68 82 6c 10 80       	push   $0x80106c82
8010466b:	8d 45 ca             	lea    -0x36(%ebp),%eax
8010466e:	50                   	push   %eax
8010466f:	e8 5b d3 ff ff       	call   801019cf <namecmp>
80104674:	83 c4 10             	add    $0x10,%esp
80104677:	85 c0                	test   %eax,%eax
80104679:	0f 84 fc 00 00 00    	je     8010477b <sys_unlink+0x161>
8010467f:	83 ec 08             	sub    $0x8,%esp
80104682:	68 81 6c 10 80       	push   $0x80106c81
80104687:	8d 45 ca             	lea    -0x36(%ebp),%eax
8010468a:	50                   	push   %eax
8010468b:	e8 3f d3 ff ff       	call   801019cf <namecmp>
80104690:	83 c4 10             	add    $0x10,%esp
80104693:	85 c0                	test   %eax,%eax
80104695:	0f 84 e0 00 00 00    	je     8010477b <sys_unlink+0x161>
  if((ip = dirlookup(dp, name, &off)) == 0)
8010469b:	83 ec 04             	sub    $0x4,%esp
8010469e:	8d 45 c0             	lea    -0x40(%ebp),%eax
801046a1:	50                   	push   %eax
801046a2:	8d 45 ca             	lea    -0x36(%ebp),%eax
801046a5:	50                   	push   %eax
801046a6:	56                   	push   %esi
801046a7:	e8 38 d3 ff ff       	call   801019e4 <dirlookup>
801046ac:	89 c3                	mov    %eax,%ebx
801046ae:	83 c4 10             	add    $0x10,%esp
801046b1:	85 c0                	test   %eax,%eax
801046b3:	0f 84 c2 00 00 00    	je     8010477b <sys_unlink+0x161>
  ilock(ip);
801046b9:	83 ec 0c             	sub    $0xc,%esp
801046bc:	50                   	push   %eax
801046bd:	e8 f3 ce ff ff       	call   801015b5 <ilock>
  if(ip->nlink < 1)
801046c2:	83 c4 10             	add    $0x10,%esp
801046c5:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
801046ca:	0f 8e 83 00 00 00    	jle    80104753 <sys_unlink+0x139>
  if(ip->type == T_DIR && !isdirempty(ip)){
801046d0:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801046d5:	0f 84 85 00 00 00    	je     80104760 <sys_unlink+0x146>
  memset(&de, 0, sizeof(de));
801046db:	83 ec 04             	sub    $0x4,%esp
801046de:	6a 10                	push   $0x10
801046e0:	6a 00                	push   $0x0
801046e2:	8d 7d d8             	lea    -0x28(%ebp),%edi
801046e5:	57                   	push   %edi
801046e6:	e8 3b f6 ff ff       	call   80103d26 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801046eb:	6a 10                	push   $0x10
801046ed:	ff 75 c0             	pushl  -0x40(%ebp)
801046f0:	57                   	push   %edi
801046f1:	56                   	push   %esi
801046f2:	e8 ad d1 ff ff       	call   801018a4 <writei>
801046f7:	83 c4 20             	add    $0x20,%esp
801046fa:	83 f8 10             	cmp    $0x10,%eax
801046fd:	0f 85 90 00 00 00    	jne    80104793 <sys_unlink+0x179>
  if(ip->type == T_DIR){
80104703:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104708:	0f 84 92 00 00 00    	je     801047a0 <sys_unlink+0x186>
  iunlockput(dp);
8010470e:	83 ec 0c             	sub    $0xc,%esp
80104711:	56                   	push   %esi
80104712:	e8 45 d0 ff ff       	call   8010175c <iunlockput>
  ip->nlink--;
80104717:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
8010471b:	83 e8 01             	sub    $0x1,%eax
8010471e:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104722:	89 1c 24             	mov    %ebx,(%esp)
80104725:	e8 2a cd ff ff       	call   80101454 <iupdate>
  iunlockput(ip);
8010472a:	89 1c 24             	mov    %ebx,(%esp)
8010472d:	e8 2a d0 ff ff       	call   8010175c <iunlockput>
  end_op();
80104732:	e8 25 e1 ff ff       	call   8010285c <end_op>
  return 0;
80104737:	83 c4 10             	add    $0x10,%esp
8010473a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010473f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104742:	5b                   	pop    %ebx
80104743:	5e                   	pop    %esi
80104744:	5f                   	pop    %edi
80104745:	5d                   	pop    %ebp
80104746:	c3                   	ret    
    end_op();
80104747:	e8 10 e1 ff ff       	call   8010285c <end_op>
    return -1;
8010474c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104751:	eb ec                	jmp    8010473f <sys_unlink+0x125>
    panic("unlink: nlink < 1");
80104753:	83 ec 0c             	sub    $0xc,%esp
80104756:	68 a0 6c 10 80       	push   $0x80106ca0
8010475b:	e8 e8 bb ff ff       	call   80100348 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80104760:	89 d8                	mov    %ebx,%eax
80104762:	e8 c4 f9 ff ff       	call   8010412b <isdirempty>
80104767:	85 c0                	test   %eax,%eax
80104769:	0f 85 6c ff ff ff    	jne    801046db <sys_unlink+0xc1>
    iunlockput(ip);
8010476f:	83 ec 0c             	sub    $0xc,%esp
80104772:	53                   	push   %ebx
80104773:	e8 e4 cf ff ff       	call   8010175c <iunlockput>
    goto bad;
80104778:	83 c4 10             	add    $0x10,%esp
  iunlockput(dp);
8010477b:	83 ec 0c             	sub    $0xc,%esp
8010477e:	56                   	push   %esi
8010477f:	e8 d8 cf ff ff       	call   8010175c <iunlockput>
  end_op();
80104784:	e8 d3 e0 ff ff       	call   8010285c <end_op>
  return -1;
80104789:	83 c4 10             	add    $0x10,%esp
8010478c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104791:	eb ac                	jmp    8010473f <sys_unlink+0x125>
    panic("unlink: writei");
80104793:	83 ec 0c             	sub    $0xc,%esp
80104796:	68 b2 6c 10 80       	push   $0x80106cb2
8010479b:	e8 a8 bb ff ff       	call   80100348 <panic>
    dp->nlink--;
801047a0:	0f b7 46 56          	movzwl 0x56(%esi),%eax
801047a4:	83 e8 01             	sub    $0x1,%eax
801047a7:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
801047ab:	83 ec 0c             	sub    $0xc,%esp
801047ae:	56                   	push   %esi
801047af:	e8 a0 cc ff ff       	call   80101454 <iupdate>
801047b4:	83 c4 10             	add    $0x10,%esp
801047b7:	e9 52 ff ff ff       	jmp    8010470e <sys_unlink+0xf4>
    return -1;
801047bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047c1:	e9 79 ff ff ff       	jmp    8010473f <sys_unlink+0x125>

801047c6 <sys_open>:

int
sys_open(void)
{
801047c6:	55                   	push   %ebp
801047c7:	89 e5                	mov    %esp,%ebp
801047c9:	57                   	push   %edi
801047ca:	56                   	push   %esi
801047cb:	53                   	push   %ebx
801047cc:	83 ec 24             	sub    $0x24,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801047cf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801047d2:	50                   	push   %eax
801047d3:	6a 00                	push   $0x0
801047d5:	e8 2b f8 ff ff       	call   80104005 <argstr>
801047da:	83 c4 10             	add    $0x10,%esp
801047dd:	85 c0                	test   %eax,%eax
801047df:	0f 88 30 01 00 00    	js     80104915 <sys_open+0x14f>
801047e5:	83 ec 08             	sub    $0x8,%esp
801047e8:	8d 45 e0             	lea    -0x20(%ebp),%eax
801047eb:	50                   	push   %eax
801047ec:	6a 01                	push   $0x1
801047ee:	e8 81 f7 ff ff       	call   80103f74 <argint>
801047f3:	83 c4 10             	add    $0x10,%esp
801047f6:	85 c0                	test   %eax,%eax
801047f8:	0f 88 21 01 00 00    	js     8010491f <sys_open+0x159>
    return -1;

  begin_op();
801047fe:	e8 df df ff ff       	call   801027e2 <begin_op>

  if(omode & O_CREATE){
80104803:	f6 45 e1 02          	testb  $0x2,-0x1f(%ebp)
80104807:	0f 84 84 00 00 00    	je     80104891 <sys_open+0xcb>
    ip = create(path, T_FILE, 0, 0);
8010480d:	83 ec 0c             	sub    $0xc,%esp
80104810:	6a 00                	push   $0x0
80104812:	b9 00 00 00 00       	mov    $0x0,%ecx
80104817:	ba 02 00 00 00       	mov    $0x2,%edx
8010481c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010481f:	e8 5e f9 ff ff       	call   80104182 <create>
80104824:	89 c6                	mov    %eax,%esi
    if(ip == 0){
80104826:	83 c4 10             	add    $0x10,%esp
80104829:	85 c0                	test   %eax,%eax
8010482b:	74 58                	je     80104885 <sys_open+0xbf>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010482d:	e8 2f c4 ff ff       	call   80100c61 <filealloc>
80104832:	89 c3                	mov    %eax,%ebx
80104834:	85 c0                	test   %eax,%eax
80104836:	0f 84 ae 00 00 00    	je     801048ea <sys_open+0x124>
8010483c:	e8 b3 f8 ff ff       	call   801040f4 <fdalloc>
80104841:	89 c7                	mov    %eax,%edi
80104843:	85 c0                	test   %eax,%eax
80104845:	0f 88 9f 00 00 00    	js     801048ea <sys_open+0x124>
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
8010484b:	83 ec 0c             	sub    $0xc,%esp
8010484e:	56                   	push   %esi
8010484f:	e8 23 ce ff ff       	call   80101677 <iunlock>
  end_op();
80104854:	e8 03 e0 ff ff       	call   8010285c <end_op>

  f->type = FD_INODE;
80104859:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
  f->ip = ip;
8010485f:	89 73 10             	mov    %esi,0x10(%ebx)
  f->off = 0;
80104862:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  f->readable = !(omode & O_WRONLY);
80104869:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010486c:	83 c4 10             	add    $0x10,%esp
8010486f:	a8 01                	test   $0x1,%al
80104871:	0f 94 43 08          	sete   0x8(%ebx)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80104875:	a8 03                	test   $0x3,%al
80104877:	0f 95 43 09          	setne  0x9(%ebx)
  return fd;
}
8010487b:	89 f8                	mov    %edi,%eax
8010487d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104880:	5b                   	pop    %ebx
80104881:	5e                   	pop    %esi
80104882:	5f                   	pop    %edi
80104883:	5d                   	pop    %ebp
80104884:	c3                   	ret    
      end_op();
80104885:	e8 d2 df ff ff       	call   8010285c <end_op>
      return -1;
8010488a:	bf ff ff ff ff       	mov    $0xffffffff,%edi
8010488f:	eb ea                	jmp    8010487b <sys_open+0xb5>
    if((ip = namei(path)) == 0){
80104891:	83 ec 0c             	sub    $0xc,%esp
80104894:	ff 75 e4             	pushl  -0x1c(%ebp)
80104897:	e8 79 d3 ff ff       	call   80101c15 <namei>
8010489c:	89 c6                	mov    %eax,%esi
8010489e:	83 c4 10             	add    $0x10,%esp
801048a1:	85 c0                	test   %eax,%eax
801048a3:	74 39                	je     801048de <sys_open+0x118>
    ilock(ip);
801048a5:	83 ec 0c             	sub    $0xc,%esp
801048a8:	50                   	push   %eax
801048a9:	e8 07 cd ff ff       	call   801015b5 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801048ae:	83 c4 10             	add    $0x10,%esp
801048b1:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
801048b6:	0f 85 71 ff ff ff    	jne    8010482d <sys_open+0x67>
801048bc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801048c0:	0f 84 67 ff ff ff    	je     8010482d <sys_open+0x67>
      iunlockput(ip);
801048c6:	83 ec 0c             	sub    $0xc,%esp
801048c9:	56                   	push   %esi
801048ca:	e8 8d ce ff ff       	call   8010175c <iunlockput>
      end_op();
801048cf:	e8 88 df ff ff       	call   8010285c <end_op>
      return -1;
801048d4:	83 c4 10             	add    $0x10,%esp
801048d7:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801048dc:	eb 9d                	jmp    8010487b <sys_open+0xb5>
      end_op();
801048de:	e8 79 df ff ff       	call   8010285c <end_op>
      return -1;
801048e3:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801048e8:	eb 91                	jmp    8010487b <sys_open+0xb5>
    if(f)
801048ea:	85 db                	test   %ebx,%ebx
801048ec:	74 0c                	je     801048fa <sys_open+0x134>
      fileclose(f);
801048ee:	83 ec 0c             	sub    $0xc,%esp
801048f1:	53                   	push   %ebx
801048f2:	e8 10 c4 ff ff       	call   80100d07 <fileclose>
801048f7:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801048fa:	83 ec 0c             	sub    $0xc,%esp
801048fd:	56                   	push   %esi
801048fe:	e8 59 ce ff ff       	call   8010175c <iunlockput>
    end_op();
80104903:	e8 54 df ff ff       	call   8010285c <end_op>
    return -1;
80104908:	83 c4 10             	add    $0x10,%esp
8010490b:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104910:	e9 66 ff ff ff       	jmp    8010487b <sys_open+0xb5>
    return -1;
80104915:	bf ff ff ff ff       	mov    $0xffffffff,%edi
8010491a:	e9 5c ff ff ff       	jmp    8010487b <sys_open+0xb5>
8010491f:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104924:	e9 52 ff ff ff       	jmp    8010487b <sys_open+0xb5>

80104929 <sys_mkdir>:

int
sys_mkdir(void)
{
80104929:	55                   	push   %ebp
8010492a:	89 e5                	mov    %esp,%ebp
8010492c:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
8010492f:	e8 ae de ff ff       	call   801027e2 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80104934:	83 ec 08             	sub    $0x8,%esp
80104937:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010493a:	50                   	push   %eax
8010493b:	6a 00                	push   $0x0
8010493d:	e8 c3 f6 ff ff       	call   80104005 <argstr>
80104942:	83 c4 10             	add    $0x10,%esp
80104945:	85 c0                	test   %eax,%eax
80104947:	78 36                	js     8010497f <sys_mkdir+0x56>
80104949:	83 ec 0c             	sub    $0xc,%esp
8010494c:	6a 00                	push   $0x0
8010494e:	b9 00 00 00 00       	mov    $0x0,%ecx
80104953:	ba 01 00 00 00       	mov    $0x1,%edx
80104958:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010495b:	e8 22 f8 ff ff       	call   80104182 <create>
80104960:	83 c4 10             	add    $0x10,%esp
80104963:	85 c0                	test   %eax,%eax
80104965:	74 18                	je     8010497f <sys_mkdir+0x56>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104967:	83 ec 0c             	sub    $0xc,%esp
8010496a:	50                   	push   %eax
8010496b:	e8 ec cd ff ff       	call   8010175c <iunlockput>
  end_op();
80104970:	e8 e7 de ff ff       	call   8010285c <end_op>
  return 0;
80104975:	83 c4 10             	add    $0x10,%esp
80104978:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010497d:	c9                   	leave  
8010497e:	c3                   	ret    
    end_op();
8010497f:	e8 d8 de ff ff       	call   8010285c <end_op>
    return -1;
80104984:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104989:	eb f2                	jmp    8010497d <sys_mkdir+0x54>

8010498b <sys_mknod>:

int
sys_mknod(void)
{
8010498b:	55                   	push   %ebp
8010498c:	89 e5                	mov    %esp,%ebp
8010498e:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80104991:	e8 4c de ff ff       	call   801027e2 <begin_op>
  if((argstr(0, &path)) < 0 ||
80104996:	83 ec 08             	sub    $0x8,%esp
80104999:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010499c:	50                   	push   %eax
8010499d:	6a 00                	push   $0x0
8010499f:	e8 61 f6 ff ff       	call   80104005 <argstr>
801049a4:	83 c4 10             	add    $0x10,%esp
801049a7:	85 c0                	test   %eax,%eax
801049a9:	78 62                	js     80104a0d <sys_mknod+0x82>
     argint(1, &major) < 0 ||
801049ab:	83 ec 08             	sub    $0x8,%esp
801049ae:	8d 45 f0             	lea    -0x10(%ebp),%eax
801049b1:	50                   	push   %eax
801049b2:	6a 01                	push   $0x1
801049b4:	e8 bb f5 ff ff       	call   80103f74 <argint>
  if((argstr(0, &path)) < 0 ||
801049b9:	83 c4 10             	add    $0x10,%esp
801049bc:	85 c0                	test   %eax,%eax
801049be:	78 4d                	js     80104a0d <sys_mknod+0x82>
     argint(2, &minor) < 0 ||
801049c0:	83 ec 08             	sub    $0x8,%esp
801049c3:	8d 45 ec             	lea    -0x14(%ebp),%eax
801049c6:	50                   	push   %eax
801049c7:	6a 02                	push   $0x2
801049c9:	e8 a6 f5 ff ff       	call   80103f74 <argint>
     argint(1, &major) < 0 ||
801049ce:	83 c4 10             	add    $0x10,%esp
801049d1:	85 c0                	test   %eax,%eax
801049d3:	78 38                	js     80104a0d <sys_mknod+0x82>
     (ip = create(path, T_DEV, major, minor)) == 0){
801049d5:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
801049d9:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
     argint(2, &minor) < 0 ||
801049dd:	83 ec 0c             	sub    $0xc,%esp
801049e0:	50                   	push   %eax
801049e1:	ba 03 00 00 00       	mov    $0x3,%edx
801049e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049e9:	e8 94 f7 ff ff       	call   80104182 <create>
801049ee:	83 c4 10             	add    $0x10,%esp
801049f1:	85 c0                	test   %eax,%eax
801049f3:	74 18                	je     80104a0d <sys_mknod+0x82>
    end_op();
    return -1;
  }
  iunlockput(ip);
801049f5:	83 ec 0c             	sub    $0xc,%esp
801049f8:	50                   	push   %eax
801049f9:	e8 5e cd ff ff       	call   8010175c <iunlockput>
  end_op();
801049fe:	e8 59 de ff ff       	call   8010285c <end_op>
  return 0;
80104a03:	83 c4 10             	add    $0x10,%esp
80104a06:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a0b:	c9                   	leave  
80104a0c:	c3                   	ret    
    end_op();
80104a0d:	e8 4a de ff ff       	call   8010285c <end_op>
    return -1;
80104a12:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a17:	eb f2                	jmp    80104a0b <sys_mknod+0x80>

80104a19 <sys_chdir>:

int
sys_chdir(void)
{
80104a19:	55                   	push   %ebp
80104a1a:	89 e5                	mov    %esp,%ebp
80104a1c:	56                   	push   %esi
80104a1d:	53                   	push   %ebx
80104a1e:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80104a21:	e8 1b e8 ff ff       	call   80103241 <myproc>
80104a26:	89 c6                	mov    %eax,%esi

  begin_op();
80104a28:	e8 b5 dd ff ff       	call   801027e2 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80104a2d:	83 ec 08             	sub    $0x8,%esp
80104a30:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104a33:	50                   	push   %eax
80104a34:	6a 00                	push   $0x0
80104a36:	e8 ca f5 ff ff       	call   80104005 <argstr>
80104a3b:	83 c4 10             	add    $0x10,%esp
80104a3e:	85 c0                	test   %eax,%eax
80104a40:	78 52                	js     80104a94 <sys_chdir+0x7b>
80104a42:	83 ec 0c             	sub    $0xc,%esp
80104a45:	ff 75 f4             	pushl  -0xc(%ebp)
80104a48:	e8 c8 d1 ff ff       	call   80101c15 <namei>
80104a4d:	89 c3                	mov    %eax,%ebx
80104a4f:	83 c4 10             	add    $0x10,%esp
80104a52:	85 c0                	test   %eax,%eax
80104a54:	74 3e                	je     80104a94 <sys_chdir+0x7b>
    end_op();
    return -1;
  }
  ilock(ip);
80104a56:	83 ec 0c             	sub    $0xc,%esp
80104a59:	50                   	push   %eax
80104a5a:	e8 56 cb ff ff       	call   801015b5 <ilock>
  if(ip->type != T_DIR){
80104a5f:	83 c4 10             	add    $0x10,%esp
80104a62:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104a67:	75 37                	jne    80104aa0 <sys_chdir+0x87>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104a69:	83 ec 0c             	sub    $0xc,%esp
80104a6c:	53                   	push   %ebx
80104a6d:	e8 05 cc ff ff       	call   80101677 <iunlock>
  iput(curproc->cwd);
80104a72:	83 c4 04             	add    $0x4,%esp
80104a75:	ff 76 6c             	pushl  0x6c(%esi)
80104a78:	e8 3f cc ff ff       	call   801016bc <iput>
  end_op();
80104a7d:	e8 da dd ff ff       	call   8010285c <end_op>
  curproc->cwd = ip;
80104a82:	89 5e 6c             	mov    %ebx,0x6c(%esi)
  return 0;
80104a85:	83 c4 10             	add    $0x10,%esp
80104a88:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a8d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104a90:	5b                   	pop    %ebx
80104a91:	5e                   	pop    %esi
80104a92:	5d                   	pop    %ebp
80104a93:	c3                   	ret    
    end_op();
80104a94:	e8 c3 dd ff ff       	call   8010285c <end_op>
    return -1;
80104a99:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a9e:	eb ed                	jmp    80104a8d <sys_chdir+0x74>
    iunlockput(ip);
80104aa0:	83 ec 0c             	sub    $0xc,%esp
80104aa3:	53                   	push   %ebx
80104aa4:	e8 b3 cc ff ff       	call   8010175c <iunlockput>
    end_op();
80104aa9:	e8 ae dd ff ff       	call   8010285c <end_op>
    return -1;
80104aae:	83 c4 10             	add    $0x10,%esp
80104ab1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ab6:	eb d5                	jmp    80104a8d <sys_chdir+0x74>

80104ab8 <sys_exec>:

int
sys_exec(void)
{
80104ab8:	55                   	push   %ebp
80104ab9:	89 e5                	mov    %esp,%ebp
80104abb:	53                   	push   %ebx
80104abc:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80104ac2:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104ac5:	50                   	push   %eax
80104ac6:	6a 00                	push   $0x0
80104ac8:	e8 38 f5 ff ff       	call   80104005 <argstr>
80104acd:	83 c4 10             	add    $0x10,%esp
80104ad0:	85 c0                	test   %eax,%eax
80104ad2:	0f 88 a8 00 00 00    	js     80104b80 <sys_exec+0xc8>
80104ad8:	83 ec 08             	sub    $0x8,%esp
80104adb:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80104ae1:	50                   	push   %eax
80104ae2:	6a 01                	push   $0x1
80104ae4:	e8 8b f4 ff ff       	call   80103f74 <argint>
80104ae9:	83 c4 10             	add    $0x10,%esp
80104aec:	85 c0                	test   %eax,%eax
80104aee:	0f 88 93 00 00 00    	js     80104b87 <sys_exec+0xcf>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
80104af4:	83 ec 04             	sub    $0x4,%esp
80104af7:	68 80 00 00 00       	push   $0x80
80104afc:	6a 00                	push   $0x0
80104afe:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104b04:	50                   	push   %eax
80104b05:	e8 1c f2 ff ff       	call   80103d26 <memset>
80104b0a:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80104b0d:	bb 00 00 00 00       	mov    $0x0,%ebx
    if(i >= NELEM(argv))
80104b12:	83 fb 1f             	cmp    $0x1f,%ebx
80104b15:	77 77                	ja     80104b8e <sys_exec+0xd6>
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80104b17:	83 ec 08             	sub    $0x8,%esp
80104b1a:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80104b20:	50                   	push   %eax
80104b21:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
80104b27:	8d 04 98             	lea    (%eax,%ebx,4),%eax
80104b2a:	50                   	push   %eax
80104b2b:	e8 c5 f3 ff ff       	call   80103ef5 <fetchint>
80104b30:	83 c4 10             	add    $0x10,%esp
80104b33:	85 c0                	test   %eax,%eax
80104b35:	78 5e                	js     80104b95 <sys_exec+0xdd>
      return -1;
    if(uarg == 0){
80104b37:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80104b3d:	85 c0                	test   %eax,%eax
80104b3f:	74 1d                	je     80104b5e <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80104b41:	83 ec 08             	sub    $0x8,%esp
80104b44:	8d 94 9d 74 ff ff ff 	lea    -0x8c(%ebp,%ebx,4),%edx
80104b4b:	52                   	push   %edx
80104b4c:	50                   	push   %eax
80104b4d:	e8 e0 f3 ff ff       	call   80103f32 <fetchstr>
80104b52:	83 c4 10             	add    $0x10,%esp
80104b55:	85 c0                	test   %eax,%eax
80104b57:	78 46                	js     80104b9f <sys_exec+0xe7>
  for(i=0;; i++){
80104b59:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
80104b5c:	eb b4                	jmp    80104b12 <sys_exec+0x5a>
      argv[i] = 0;
80104b5e:	c7 84 9d 74 ff ff ff 	movl   $0x0,-0x8c(%ebp,%ebx,4)
80104b65:	00 00 00 00 
      return -1;
  }
  return exec(path, argv);
80104b69:	83 ec 08             	sub    $0x8,%esp
80104b6c:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104b72:	50                   	push   %eax
80104b73:	ff 75 f4             	pushl  -0xc(%ebp)
80104b76:	e8 9a bd ff ff       	call   80100915 <exec>
80104b7b:	83 c4 10             	add    $0x10,%esp
80104b7e:	eb 1a                	jmp    80104b9a <sys_exec+0xe2>
    return -1;
80104b80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b85:	eb 13                	jmp    80104b9a <sys_exec+0xe2>
80104b87:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b8c:	eb 0c                	jmp    80104b9a <sys_exec+0xe2>
      return -1;
80104b8e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b93:	eb 05                	jmp    80104b9a <sys_exec+0xe2>
      return -1;
80104b95:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104b9a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104b9d:	c9                   	leave  
80104b9e:	c3                   	ret    
      return -1;
80104b9f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ba4:	eb f4                	jmp    80104b9a <sys_exec+0xe2>

80104ba6 <sys_pipe>:

int
sys_pipe(void)
{
80104ba6:	55                   	push   %ebp
80104ba7:	89 e5                	mov    %esp,%ebp
80104ba9:	53                   	push   %ebx
80104baa:	83 ec 18             	sub    $0x18,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80104bad:	6a 08                	push   $0x8
80104baf:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104bb2:	50                   	push   %eax
80104bb3:	6a 00                	push   $0x0
80104bb5:	e8 e2 f3 ff ff       	call   80103f9c <argptr>
80104bba:	83 c4 10             	add    $0x10,%esp
80104bbd:	85 c0                	test   %eax,%eax
80104bbf:	78 77                	js     80104c38 <sys_pipe+0x92>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80104bc1:	83 ec 08             	sub    $0x8,%esp
80104bc4:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104bc7:	50                   	push   %eax
80104bc8:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104bcb:	50                   	push   %eax
80104bcc:	e8 98 e1 ff ff       	call   80102d69 <pipealloc>
80104bd1:	83 c4 10             	add    $0x10,%esp
80104bd4:	85 c0                	test   %eax,%eax
80104bd6:	78 67                	js     80104c3f <sys_pipe+0x99>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80104bd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104bdb:	e8 14 f5 ff ff       	call   801040f4 <fdalloc>
80104be0:	89 c3                	mov    %eax,%ebx
80104be2:	85 c0                	test   %eax,%eax
80104be4:	78 21                	js     80104c07 <sys_pipe+0x61>
80104be6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104be9:	e8 06 f5 ff ff       	call   801040f4 <fdalloc>
80104bee:	85 c0                	test   %eax,%eax
80104bf0:	78 15                	js     80104c07 <sys_pipe+0x61>
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
80104bf2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104bf5:	89 1a                	mov    %ebx,(%edx)
  fd[1] = fd1;
80104bf7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104bfa:	89 42 04             	mov    %eax,0x4(%edx)
  return 0;
80104bfd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104c02:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c05:	c9                   	leave  
80104c06:	c3                   	ret    
    if(fd0 >= 0)
80104c07:	85 db                	test   %ebx,%ebx
80104c09:	78 0d                	js     80104c18 <sys_pipe+0x72>
      myproc()->ofile[fd0] = 0;
80104c0b:	e8 31 e6 ff ff       	call   80103241 <myproc>
80104c10:	c7 44 98 2c 00 00 00 	movl   $0x0,0x2c(%eax,%ebx,4)
80104c17:	00 
    fileclose(rf);
80104c18:	83 ec 0c             	sub    $0xc,%esp
80104c1b:	ff 75 f0             	pushl  -0x10(%ebp)
80104c1e:	e8 e4 c0 ff ff       	call   80100d07 <fileclose>
    fileclose(wf);
80104c23:	83 c4 04             	add    $0x4,%esp
80104c26:	ff 75 ec             	pushl  -0x14(%ebp)
80104c29:	e8 d9 c0 ff ff       	call   80100d07 <fileclose>
    return -1;
80104c2e:	83 c4 10             	add    $0x10,%esp
80104c31:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c36:	eb ca                	jmp    80104c02 <sys_pipe+0x5c>
    return -1;
80104c38:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c3d:	eb c3                	jmp    80104c02 <sys_pipe+0x5c>
    return -1;
80104c3f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c44:	eb bc                	jmp    80104c02 <sys_pipe+0x5c>

80104c46 <sys_fork>:
#include "pdx-kernel.h"
#endif // PDX_XV6

int
sys_fork(void)
{
80104c46:	55                   	push   %ebp
80104c47:	89 e5                	mov    %esp,%ebp
80104c49:	83 ec 08             	sub    $0x8,%esp
  return fork();
80104c4c:	e8 6b e7 ff ff       	call   801033bc <fork>
}
80104c51:	c9                   	leave  
80104c52:	c3                   	ret    

80104c53 <sys_exit>:

int
sys_exit(void)
{
80104c53:	55                   	push   %ebp
80104c54:	89 e5                	mov    %esp,%ebp
80104c56:	83 ec 08             	sub    $0x8,%esp
  exit();
80104c59:	e8 a9 e9 ff ff       	call   80103607 <exit>
  return 0;  // not reached
}
80104c5e:	b8 00 00 00 00       	mov    $0x0,%eax
80104c63:	c9                   	leave  
80104c64:	c3                   	ret    

80104c65 <sys_wait>:

int
sys_wait(void)
{
80104c65:	55                   	push   %ebp
80104c66:	89 e5                	mov    %esp,%ebp
80104c68:	83 ec 08             	sub    $0x8,%esp
  return wait();
80104c6b:	e8 2f eb ff ff       	call   8010379f <wait>
}
80104c70:	c9                   	leave  
80104c71:	c3                   	ret    

80104c72 <sys_kill>:

int
sys_kill(void)
{
80104c72:	55                   	push   %ebp
80104c73:	89 e5                	mov    %esp,%ebp
80104c75:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80104c78:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104c7b:	50                   	push   %eax
80104c7c:	6a 00                	push   $0x0
80104c7e:	e8 f1 f2 ff ff       	call   80103f74 <argint>
80104c83:	83 c4 10             	add    $0x10,%esp
80104c86:	85 c0                	test   %eax,%eax
80104c88:	78 10                	js     80104c9a <sys_kill+0x28>
    return -1;
  return kill(pid);
80104c8a:	83 ec 0c             	sub    $0xc,%esp
80104c8d:	ff 75 f4             	pushl  -0xc(%ebp)
80104c90:	e8 07 ec ff ff       	call   8010389c <kill>
80104c95:	83 c4 10             	add    $0x10,%esp
}
80104c98:	c9                   	leave  
80104c99:	c3                   	ret    
    return -1;
80104c9a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c9f:	eb f7                	jmp    80104c98 <sys_kill+0x26>

80104ca1 <sys_getpid>:

int
sys_getpid(void)
{
80104ca1:	55                   	push   %ebp
80104ca2:	89 e5                	mov    %esp,%ebp
80104ca4:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80104ca7:	e8 95 e5 ff ff       	call   80103241 <myproc>
80104cac:	8b 40 14             	mov    0x14(%eax),%eax
}
80104caf:	c9                   	leave  
80104cb0:	c3                   	ret    

80104cb1 <sys_sbrk>:

int
sys_sbrk(void)
{
80104cb1:	55                   	push   %ebp
80104cb2:	89 e5                	mov    %esp,%ebp
80104cb4:	53                   	push   %ebx
80104cb5:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80104cb8:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104cbb:	50                   	push   %eax
80104cbc:	6a 00                	push   $0x0
80104cbe:	e8 b1 f2 ff ff       	call   80103f74 <argint>
80104cc3:	83 c4 10             	add    $0x10,%esp
80104cc6:	85 c0                	test   %eax,%eax
80104cc8:	78 28                	js     80104cf2 <sys_sbrk+0x41>
    return -1;
  addr = myproc()->sz;
80104cca:	e8 72 e5 ff ff       	call   80103241 <myproc>
80104ccf:	8b 58 04             	mov    0x4(%eax),%ebx
  if(growproc(n) < 0)
80104cd2:	83 ec 0c             	sub    $0xc,%esp
80104cd5:	ff 75 f4             	pushl  -0xc(%ebp)
80104cd8:	e8 70 e6 ff ff       	call   8010334d <growproc>
80104cdd:	83 c4 10             	add    $0x10,%esp
80104ce0:	85 c0                	test   %eax,%eax
80104ce2:	78 07                	js     80104ceb <sys_sbrk+0x3a>
    return -1;
  return addr;
}
80104ce4:	89 d8                	mov    %ebx,%eax
80104ce6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104ce9:	c9                   	leave  
80104cea:	c3                   	ret    
    return -1;
80104ceb:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104cf0:	eb f2                	jmp    80104ce4 <sys_sbrk+0x33>
    return -1;
80104cf2:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104cf7:	eb eb                	jmp    80104ce4 <sys_sbrk+0x33>

80104cf9 <sys_date>:

int
sys_date ( void )
{
80104cf9:	55                   	push   %ebp
80104cfa:	89 e5                	mov    %esp,%ebp
80104cfc:	83 ec 1c             	sub    $0x1c,%esp
  struct rtcdate *d ;
  if (argptr ( 0 ,( void*)&d , sizeof ( struct rtcdate)) < 0)
80104cff:	6a 18                	push   $0x18
80104d01:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d04:	50                   	push   %eax
80104d05:	6a 00                	push   $0x0
80104d07:	e8 90 f2 ff ff       	call   80103f9c <argptr>
80104d0c:	83 c4 10             	add    $0x10,%esp
80104d0f:	85 c0                	test   %eax,%eax
80104d11:	78 15                	js     80104d28 <sys_date+0x2f>
    return -1;
  cmostime(d);
80104d13:	83 ec 0c             	sub    $0xc,%esp
80104d16:	ff 75 f4             	pushl  -0xc(%ebp)
80104d19:	e8 68 d7 ff ff       	call   80102486 <cmostime>
  return 0;
80104d1e:	83 c4 10             	add    $0x10,%esp
80104d21:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104d26:	c9                   	leave  
80104d27:	c3                   	ret    
    return -1;
80104d28:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d2d:	eb f7                	jmp    80104d26 <sys_date+0x2d>

80104d2f <sys_sleep>:

int
sys_sleep(void)
{
80104d2f:	55                   	push   %ebp
80104d30:	89 e5                	mov    %esp,%ebp
80104d32:	53                   	push   %ebx
80104d33:	83 ec 1c             	sub    $0x1c,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80104d36:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d39:	50                   	push   %eax
80104d3a:	6a 00                	push   $0x0
80104d3c:	e8 33 f2 ff ff       	call   80103f74 <argint>
80104d41:	83 c4 10             	add    $0x10,%esp
80104d44:	85 c0                	test   %eax,%eax
80104d46:	78 3b                	js     80104d83 <sys_sleep+0x54>
    return -1;
  ticks0 = ticks;
80104d48:	8b 1d 80 45 11 80    	mov    0x80114580,%ebx
  while(ticks - ticks0 < n){
80104d4e:	a1 80 45 11 80       	mov    0x80114580,%eax
80104d53:	29 d8                	sub    %ebx,%eax
80104d55:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104d58:	73 1f                	jae    80104d79 <sys_sleep+0x4a>
    if(myproc()->killed){
80104d5a:	e8 e2 e4 ff ff       	call   80103241 <myproc>
80104d5f:	83 78 28 00          	cmpl   $0x0,0x28(%eax)
80104d63:	75 25                	jne    80104d8a <sys_sleep+0x5b>
      return -1;
    }
    sleep(&ticks, (struct spinlock *)0);
80104d65:	83 ec 08             	sub    $0x8,%esp
80104d68:	6a 00                	push   $0x0
80104d6a:	68 80 45 11 80       	push   $0x80114580
80104d6f:	e8 9b e9 ff ff       	call   8010370f <sleep>
80104d74:	83 c4 10             	add    $0x10,%esp
80104d77:	eb d5                	jmp    80104d4e <sys_sleep+0x1f>
  }
  return 0;
80104d79:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104d7e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104d81:	c9                   	leave  
80104d82:	c3                   	ret    
    return -1;
80104d83:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d88:	eb f4                	jmp    80104d7e <sys_sleep+0x4f>
      return -1;
80104d8a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d8f:	eb ed                	jmp    80104d7e <sys_sleep+0x4f>

80104d91 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80104d91:	55                   	push   %ebp
80104d92:	89 e5                	mov    %esp,%ebp
  uint xticks;

  xticks = ticks;
  return xticks;
}
80104d94:	a1 80 45 11 80       	mov    0x80114580,%eax
80104d99:	5d                   	pop    %ebp
80104d9a:	c3                   	ret    

80104d9b <sys_halt>:

#ifdef PDX_XV6
// shutdown QEMU
int
sys_halt(void)
{
80104d9b:	55                   	push   %ebp
80104d9c:	89 e5                	mov    %esp,%ebp
80104d9e:	83 ec 08             	sub    $0x8,%esp
  do_shutdown();  // never returns
80104da1:	e8 98 b9 ff ff       	call   8010073e <do_shutdown>
  return 0;
}
80104da6:	b8 00 00 00 00       	mov    $0x0,%eax
80104dab:	c9                   	leave  
80104dac:	c3                   	ret    

80104dad <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80104dad:	1e                   	push   %ds
  pushl %es
80104dae:	06                   	push   %es
  pushl %fs
80104daf:	0f a0                	push   %fs
  pushl %gs
80104db1:	0f a8                	push   %gs
  pushal
80104db3:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80104db4:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80104db8:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80104dba:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80104dbc:	54                   	push   %esp
  call trap
80104dbd:	e8 cb 00 00 00       	call   80104e8d <trap>
  addl $4, %esp
80104dc2:	83 c4 04             	add    $0x4,%esp

80104dc5 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80104dc5:	61                   	popa   
  popl %gs
80104dc6:	0f a9                	pop    %gs
  popl %fs
80104dc8:	0f a1                	pop    %fs
  popl %es
80104dca:	07                   	pop    %es
  popl %ds
80104dcb:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80104dcc:	83 c4 08             	add    $0x8,%esp
  iret
80104dcf:	cf                   	iret   

80104dd0 <tvinit>:
uint ticks;
#endif // PDX_XV6

void
tvinit(void)
{
80104dd0:	55                   	push   %ebp
80104dd1:	89 e5                	mov    %esp,%ebp
  int i;

  for(i = 0; i < 256; i++)
80104dd3:	b8 00 00 00 00       	mov    $0x0,%eax
80104dd8:	eb 4a                	jmp    80104e24 <tvinit+0x54>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80104dda:	8b 0c 85 08 90 10 80 	mov    -0x7fef6ff8(,%eax,4),%ecx
80104de1:	66 89 0c c5 80 3d 11 	mov    %cx,-0x7feec280(,%eax,8)
80104de8:	80 
80104de9:	66 c7 04 c5 82 3d 11 	movw   $0x8,-0x7feec27e(,%eax,8)
80104df0:	80 08 00 
80104df3:	c6 04 c5 84 3d 11 80 	movb   $0x0,-0x7feec27c(,%eax,8)
80104dfa:	00 
80104dfb:	0f b6 14 c5 85 3d 11 	movzbl -0x7feec27b(,%eax,8),%edx
80104e02:	80 
80104e03:	83 e2 f0             	and    $0xfffffff0,%edx
80104e06:	83 ca 0e             	or     $0xe,%edx
80104e09:	83 e2 8f             	and    $0xffffff8f,%edx
80104e0c:	83 ca 80             	or     $0xffffff80,%edx
80104e0f:	88 14 c5 85 3d 11 80 	mov    %dl,-0x7feec27b(,%eax,8)
80104e16:	c1 e9 10             	shr    $0x10,%ecx
80104e19:	66 89 0c c5 86 3d 11 	mov    %cx,-0x7feec27a(,%eax,8)
80104e20:	80 
  for(i = 0; i < 256; i++)
80104e21:	83 c0 01             	add    $0x1,%eax
80104e24:	3d ff 00 00 00       	cmp    $0xff,%eax
80104e29:	7e af                	jle    80104dda <tvinit+0xa>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80104e2b:	8b 15 08 91 10 80    	mov    0x80109108,%edx
80104e31:	66 89 15 80 3f 11 80 	mov    %dx,0x80113f80
80104e38:	66 c7 05 82 3f 11 80 	movw   $0x8,0x80113f82
80104e3f:	08 00 
80104e41:	c6 05 84 3f 11 80 00 	movb   $0x0,0x80113f84
80104e48:	0f b6 05 85 3f 11 80 	movzbl 0x80113f85,%eax
80104e4f:	83 c8 0f             	or     $0xf,%eax
80104e52:	83 e0 ef             	and    $0xffffffef,%eax
80104e55:	83 c8 e0             	or     $0xffffffe0,%eax
80104e58:	a2 85 3f 11 80       	mov    %al,0x80113f85
80104e5d:	c1 ea 10             	shr    $0x10,%edx
80104e60:	66 89 15 86 3f 11 80 	mov    %dx,0x80113f86

#ifndef PDX_XV6
  initlock(&tickslock, "time");
#endif // PDX_XV6
}
80104e67:	5d                   	pop    %ebp
80104e68:	c3                   	ret    

80104e69 <idtinit>:

void
idtinit(void)
{
80104e69:	55                   	push   %ebp
80104e6a:	89 e5                	mov    %esp,%ebp
80104e6c:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80104e6f:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
80104e75:	b8 80 3d 11 80       	mov    $0x80113d80,%eax
80104e7a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80104e7e:	c1 e8 10             	shr    $0x10,%eax
80104e81:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80104e85:	8d 45 fa             	lea    -0x6(%ebp),%eax
80104e88:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
80104e8b:	c9                   	leave  
80104e8c:	c3                   	ret    

80104e8d <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80104e8d:	55                   	push   %ebp
80104e8e:	89 e5                	mov    %esp,%ebp
80104e90:	57                   	push   %edi
80104e91:	56                   	push   %esi
80104e92:	53                   	push   %ebx
80104e93:	83 ec 1c             	sub    $0x1c,%esp
80104e96:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
80104e99:	8b 43 30             	mov    0x30(%ebx),%eax
80104e9c:	83 f8 40             	cmp    $0x40,%eax
80104e9f:	74 13                	je     80104eb4 <trap+0x27>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
80104ea1:	83 e8 20             	sub    $0x20,%eax
80104ea4:	83 f8 1f             	cmp    $0x1f,%eax
80104ea7:	0f 87 22 01 00 00    	ja     80104fcf <trap+0x142>
80104ead:	ff 24 85 64 6d 10 80 	jmp    *-0x7fef929c(,%eax,4)
    if(myproc()->killed)
80104eb4:	e8 88 e3 ff ff       	call   80103241 <myproc>
80104eb9:	83 78 28 00          	cmpl   $0x0,0x28(%eax)
80104ebd:	75 1f                	jne    80104ede <trap+0x51>
    myproc()->tf = tf;
80104ebf:	e8 7d e3 ff ff       	call   80103241 <myproc>
80104ec4:	89 58 1c             	mov    %ebx,0x1c(%eax)
    syscall();
80104ec7:	e8 6c f1 ff ff       	call   80104038 <syscall>
    if(myproc()->killed)
80104ecc:	e8 70 e3 ff ff       	call   80103241 <myproc>
80104ed1:	83 78 28 00          	cmpl   $0x0,0x28(%eax)
80104ed5:	74 7e                	je     80104f55 <trap+0xc8>
      exit();
80104ed7:	e8 2b e7 ff ff       	call   80103607 <exit>
80104edc:	eb 77                	jmp    80104f55 <trap+0xc8>
      exit();
80104ede:	e8 24 e7 ff ff       	call   80103607 <exit>
80104ee3:	eb da                	jmp    80104ebf <trap+0x32>
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80104ee5:	e8 3c e3 ff ff       	call   80103226 <cpuid>
80104eea:	85 c0                	test   %eax,%eax
80104eec:	74 6f                	je     80104f5d <trap+0xd0>
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
#endif // PDX_XV6
    }
    lapiceoi();
80104eee:	e8 da d4 ff ff       	call   801023cd <lapiceoi>
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80104ef3:	e8 49 e3 ff ff       	call   80103241 <myproc>
80104ef8:	85 c0                	test   %eax,%eax
80104efa:	74 1c                	je     80104f18 <trap+0x8b>
80104efc:	e8 40 e3 ff ff       	call   80103241 <myproc>
80104f01:	83 78 28 00          	cmpl   $0x0,0x28(%eax)
80104f05:	74 11                	je     80104f18 <trap+0x8b>
80104f07:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80104f0b:	83 e0 03             	and    $0x3,%eax
80104f0e:	66 83 f8 03          	cmp    $0x3,%ax
80104f12:	0f 84 4a 01 00 00    	je     80105062 <trap+0x1d5>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80104f18:	e8 24 e3 ff ff       	call   80103241 <myproc>
80104f1d:	85 c0                	test   %eax,%eax
80104f1f:	74 0f                	je     80104f30 <trap+0xa3>
80104f21:	e8 1b e3 ff ff       	call   80103241 <myproc>
80104f26:	83 78 10 04          	cmpl   $0x4,0x10(%eax)
80104f2a:	0f 84 3c 01 00 00    	je     8010506c <trap+0x1df>
    tf->trapno == T_IRQ0+IRQ_TIMER)
#endif // PDX_XV6
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80104f30:	e8 0c e3 ff ff       	call   80103241 <myproc>
80104f35:	85 c0                	test   %eax,%eax
80104f37:	74 1c                	je     80104f55 <trap+0xc8>
80104f39:	e8 03 e3 ff ff       	call   80103241 <myproc>
80104f3e:	83 78 28 00          	cmpl   $0x0,0x28(%eax)
80104f42:	74 11                	je     80104f55 <trap+0xc8>
80104f44:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80104f48:	83 e0 03             	and    $0x3,%eax
80104f4b:	66 83 f8 03          	cmp    $0x3,%ax
80104f4f:	0f 84 4b 01 00 00    	je     801050a0 <trap+0x213>
    exit();
}
80104f55:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104f58:	5b                   	pop    %ebx
80104f59:	5e                   	pop    %esi
80104f5a:	5f                   	pop    %edi
80104f5b:	5d                   	pop    %ebp
80104f5c:	c3                   	ret    
// atom_inc() necessary for removal of tickslock
// other atomic ops added for completeness
static inline void
atom_inc(volatile int *num)
{
  asm volatile ( "lock incl %0" : "=m" (*num));
80104f5d:	f0 ff 05 80 45 11 80 	lock incl 0x80114580
      wakeup(&ticks);
80104f64:	83 ec 0c             	sub    $0xc,%esp
80104f67:	68 80 45 11 80       	push   $0x80114580
80104f6c:	e8 02 e9 ff ff       	call   80103873 <wakeup>
80104f71:	83 c4 10             	add    $0x10,%esp
80104f74:	e9 75 ff ff ff       	jmp    80104eee <trap+0x61>
    ideintr();
80104f79:	e8 29 ce ff ff       	call   80101da7 <ideintr>
    lapiceoi();
80104f7e:	e8 4a d4 ff ff       	call   801023cd <lapiceoi>
    break;
80104f83:	e9 6b ff ff ff       	jmp    80104ef3 <trap+0x66>
    kbdintr();
80104f88:	e8 84 d2 ff ff       	call   80102211 <kbdintr>
    lapiceoi();
80104f8d:	e8 3b d4 ff ff       	call   801023cd <lapiceoi>
    break;
80104f92:	e9 5c ff ff ff       	jmp    80104ef3 <trap+0x66>
    uartintr();
80104f97:	e8 25 02 00 00       	call   801051c1 <uartintr>
    lapiceoi();
80104f9c:	e8 2c d4 ff ff       	call   801023cd <lapiceoi>
    break;
80104fa1:	e9 4d ff ff ff       	jmp    80104ef3 <trap+0x66>
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80104fa6:	8b 7b 38             	mov    0x38(%ebx),%edi
            cpuid(), tf->cs, tf->eip);
80104fa9:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80104fad:	e8 74 e2 ff ff       	call   80103226 <cpuid>
80104fb2:	57                   	push   %edi
80104fb3:	0f b7 f6             	movzwl %si,%esi
80104fb6:	56                   	push   %esi
80104fb7:	50                   	push   %eax
80104fb8:	68 c4 6c 10 80       	push   $0x80106cc4
80104fbd:	e8 49 b6 ff ff       	call   8010060b <cprintf>
    lapiceoi();
80104fc2:	e8 06 d4 ff ff       	call   801023cd <lapiceoi>
    break;
80104fc7:	83 c4 10             	add    $0x10,%esp
80104fca:	e9 24 ff ff ff       	jmp    80104ef3 <trap+0x66>
    if(myproc() == 0 || (tf->cs&3) == 0){
80104fcf:	e8 6d e2 ff ff       	call   80103241 <myproc>
80104fd4:	85 c0                	test   %eax,%eax
80104fd6:	74 5f                	je     80105037 <trap+0x1aa>
80104fd8:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
80104fdc:	74 59                	je     80105037 <trap+0x1aa>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80104fde:	0f 20 d7             	mov    %cr2,%edi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80104fe1:	8b 43 38             	mov    0x38(%ebx),%eax
80104fe4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80104fe7:	e8 3a e2 ff ff       	call   80103226 <cpuid>
80104fec:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104fef:	8b 4b 34             	mov    0x34(%ebx),%ecx
80104ff2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
80104ff5:	8b 73 30             	mov    0x30(%ebx),%esi
            myproc()->pid, myproc()->name, tf->trapno,
80104ff8:	e8 44 e2 ff ff       	call   80103241 <myproc>
80104ffd:	8d 50 70             	lea    0x70(%eax),%edx
80105000:	89 55 d8             	mov    %edx,-0x28(%ebp)
80105003:	e8 39 e2 ff ff       	call   80103241 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105008:	57                   	push   %edi
80105009:	ff 75 e4             	pushl  -0x1c(%ebp)
8010500c:	ff 75 e0             	pushl  -0x20(%ebp)
8010500f:	ff 75 dc             	pushl  -0x24(%ebp)
80105012:	56                   	push   %esi
80105013:	ff 75 d8             	pushl  -0x28(%ebp)
80105016:	ff 70 14             	pushl  0x14(%eax)
80105019:	68 1c 6d 10 80       	push   $0x80106d1c
8010501e:	e8 e8 b5 ff ff       	call   8010060b <cprintf>
    myproc()->killed = 1;
80105023:	83 c4 20             	add    $0x20,%esp
80105026:	e8 16 e2 ff ff       	call   80103241 <myproc>
8010502b:	c7 40 28 01 00 00 00 	movl   $0x1,0x28(%eax)
80105032:	e9 bc fe ff ff       	jmp    80104ef3 <trap+0x66>
80105037:	0f 20 d7             	mov    %cr2,%edi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010503a:	8b 73 38             	mov    0x38(%ebx),%esi
8010503d:	e8 e4 e1 ff ff       	call   80103226 <cpuid>
80105042:	83 ec 0c             	sub    $0xc,%esp
80105045:	57                   	push   %edi
80105046:	56                   	push   %esi
80105047:	50                   	push   %eax
80105048:	ff 73 30             	pushl  0x30(%ebx)
8010504b:	68 e8 6c 10 80       	push   $0x80106ce8
80105050:	e8 b6 b5 ff ff       	call   8010060b <cprintf>
      panic("trap");
80105055:	83 c4 14             	add    $0x14,%esp
80105058:	68 5f 6d 10 80       	push   $0x80106d5f
8010505d:	e8 e6 b2 ff ff       	call   80100348 <panic>
    exit();
80105062:	e8 a0 e5 ff ff       	call   80103607 <exit>
80105067:	e9 ac fe ff ff       	jmp    80104f18 <trap+0x8b>
  if(myproc() && myproc()->state == RUNNING &&
8010506c:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
80105070:	0f 85 ba fe ff ff    	jne    80104f30 <trap+0xa3>
    tf->trapno == T_IRQ0+IRQ_TIMER && ticks%SCHED_INTERVAL==0)
80105076:	8b 0d 80 45 11 80    	mov    0x80114580,%ecx
8010507c:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
80105081:	89 c8                	mov    %ecx,%eax
80105083:	f7 e2                	mul    %edx
80105085:	c1 ea 03             	shr    $0x3,%edx
80105088:	8d 14 92             	lea    (%edx,%edx,4),%edx
8010508b:	8d 04 12             	lea    (%edx,%edx,1),%eax
8010508e:	39 c1                	cmp    %eax,%ecx
80105090:	0f 85 9a fe ff ff    	jne    80104f30 <trap+0xa3>
    yield();
80105096:	e8 39 e6 ff ff       	call   801036d4 <yield>
8010509b:	e9 90 fe ff ff       	jmp    80104f30 <trap+0xa3>
    exit();
801050a0:	e8 62 e5 ff ff       	call   80103607 <exit>
801050a5:	e9 ab fe ff ff       	jmp    80104f55 <trap+0xc8>

801050aa <uartgetc>:
  outb(COM1+0, c);
}

static int
uartgetc(void)
{
801050aa:	55                   	push   %ebp
801050ab:	89 e5                	mov    %esp,%ebp
  if(!uart)
801050ad:	83 3d 14 b6 10 80 00 	cmpl   $0x0,0x8010b614
801050b4:	74 15                	je     801050cb <uartgetc+0x21>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801050b6:	ba fd 03 00 00       	mov    $0x3fd,%edx
801050bb:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
801050bc:	a8 01                	test   $0x1,%al
801050be:	74 12                	je     801050d2 <uartgetc+0x28>
801050c0:	ba f8 03 00 00       	mov    $0x3f8,%edx
801050c5:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
801050c6:	0f b6 c0             	movzbl %al,%eax
}
801050c9:	5d                   	pop    %ebp
801050ca:	c3                   	ret    
    return -1;
801050cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050d0:	eb f7                	jmp    801050c9 <uartgetc+0x1f>
    return -1;
801050d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050d7:	eb f0                	jmp    801050c9 <uartgetc+0x1f>

801050d9 <uartputc>:
  if(!uart)
801050d9:	83 3d 14 b6 10 80 00 	cmpl   $0x0,0x8010b614
801050e0:	74 3b                	je     8010511d <uartputc+0x44>
{
801050e2:	55                   	push   %ebp
801050e3:	89 e5                	mov    %esp,%ebp
801050e5:	53                   	push   %ebx
801050e6:	83 ec 04             	sub    $0x4,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801050e9:	bb 00 00 00 00       	mov    $0x0,%ebx
801050ee:	eb 10                	jmp    80105100 <uartputc+0x27>
    microdelay(10);
801050f0:	83 ec 0c             	sub    $0xc,%esp
801050f3:	6a 0a                	push   $0xa
801050f5:	e8 f2 d2 ff ff       	call   801023ec <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801050fa:	83 c3 01             	add    $0x1,%ebx
801050fd:	83 c4 10             	add    $0x10,%esp
80105100:	83 fb 7f             	cmp    $0x7f,%ebx
80105103:	7f 0a                	jg     8010510f <uartputc+0x36>
80105105:	ba fd 03 00 00       	mov    $0x3fd,%edx
8010510a:	ec                   	in     (%dx),%al
8010510b:	a8 20                	test   $0x20,%al
8010510d:	74 e1                	je     801050f0 <uartputc+0x17>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010510f:	8b 45 08             	mov    0x8(%ebp),%eax
80105112:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105117:	ee                   	out    %al,(%dx)
}
80105118:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010511b:	c9                   	leave  
8010511c:	c3                   	ret    
8010511d:	f3 c3                	repz ret 

8010511f <uartinit>:
{
8010511f:	55                   	push   %ebp
80105120:	89 e5                	mov    %esp,%ebp
80105122:	56                   	push   %esi
80105123:	53                   	push   %ebx
80105124:	b9 00 00 00 00       	mov    $0x0,%ecx
80105129:	ba fa 03 00 00       	mov    $0x3fa,%edx
8010512e:	89 c8                	mov    %ecx,%eax
80105130:	ee                   	out    %al,(%dx)
80105131:	be fb 03 00 00       	mov    $0x3fb,%esi
80105136:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
8010513b:	89 f2                	mov    %esi,%edx
8010513d:	ee                   	out    %al,(%dx)
8010513e:	b8 0c 00 00 00       	mov    $0xc,%eax
80105143:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105148:	ee                   	out    %al,(%dx)
80105149:	bb f9 03 00 00       	mov    $0x3f9,%ebx
8010514e:	89 c8                	mov    %ecx,%eax
80105150:	89 da                	mov    %ebx,%edx
80105152:	ee                   	out    %al,(%dx)
80105153:	b8 03 00 00 00       	mov    $0x3,%eax
80105158:	89 f2                	mov    %esi,%edx
8010515a:	ee                   	out    %al,(%dx)
8010515b:	ba fc 03 00 00       	mov    $0x3fc,%edx
80105160:	89 c8                	mov    %ecx,%eax
80105162:	ee                   	out    %al,(%dx)
80105163:	b8 01 00 00 00       	mov    $0x1,%eax
80105168:	89 da                	mov    %ebx,%edx
8010516a:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010516b:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105170:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
80105171:	3c ff                	cmp    $0xff,%al
80105173:	74 45                	je     801051ba <uartinit+0x9b>
  uart = 1;
80105175:	c7 05 14 b6 10 80 01 	movl   $0x1,0x8010b614
8010517c:	00 00 00 
8010517f:	ba fa 03 00 00       	mov    $0x3fa,%edx
80105184:	ec                   	in     (%dx),%al
80105185:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010518a:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
8010518b:	83 ec 08             	sub    $0x8,%esp
8010518e:	6a 00                	push   $0x0
80105190:	6a 04                	push   $0x4
80105192:	e8 1b ce ff ff       	call   80101fb2 <ioapicenable>
  for(p="xv6...\n"; *p; p++)
80105197:	83 c4 10             	add    $0x10,%esp
8010519a:	bb e4 6d 10 80       	mov    $0x80106de4,%ebx
8010519f:	eb 12                	jmp    801051b3 <uartinit+0x94>
    uartputc(*p);
801051a1:	83 ec 0c             	sub    $0xc,%esp
801051a4:	0f be c0             	movsbl %al,%eax
801051a7:	50                   	push   %eax
801051a8:	e8 2c ff ff ff       	call   801050d9 <uartputc>
  for(p="xv6...\n"; *p; p++)
801051ad:	83 c3 01             	add    $0x1,%ebx
801051b0:	83 c4 10             	add    $0x10,%esp
801051b3:	0f b6 03             	movzbl (%ebx),%eax
801051b6:	84 c0                	test   %al,%al
801051b8:	75 e7                	jne    801051a1 <uartinit+0x82>
}
801051ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
801051bd:	5b                   	pop    %ebx
801051be:	5e                   	pop    %esi
801051bf:	5d                   	pop    %ebp
801051c0:	c3                   	ret    

801051c1 <uartintr>:

void
uartintr(void)
{
801051c1:	55                   	push   %ebp
801051c2:	89 e5                	mov    %esp,%ebp
801051c4:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
801051c7:	68 aa 50 10 80       	push   $0x801050aa
801051cc:	e8 8e b5 ff ff       	call   8010075f <consoleintr>
}
801051d1:	83 c4 10             	add    $0x10,%esp
801051d4:	c9                   	leave  
801051d5:	c3                   	ret    

801051d6 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801051d6:	6a 00                	push   $0x0
  pushl $0
801051d8:	6a 00                	push   $0x0
  jmp alltraps
801051da:	e9 ce fb ff ff       	jmp    80104dad <alltraps>

801051df <vector1>:
.globl vector1
vector1:
  pushl $0
801051df:	6a 00                	push   $0x0
  pushl $1
801051e1:	6a 01                	push   $0x1
  jmp alltraps
801051e3:	e9 c5 fb ff ff       	jmp    80104dad <alltraps>

801051e8 <vector2>:
.globl vector2
vector2:
  pushl $0
801051e8:	6a 00                	push   $0x0
  pushl $2
801051ea:	6a 02                	push   $0x2
  jmp alltraps
801051ec:	e9 bc fb ff ff       	jmp    80104dad <alltraps>

801051f1 <vector3>:
.globl vector3
vector3:
  pushl $0
801051f1:	6a 00                	push   $0x0
  pushl $3
801051f3:	6a 03                	push   $0x3
  jmp alltraps
801051f5:	e9 b3 fb ff ff       	jmp    80104dad <alltraps>

801051fa <vector4>:
.globl vector4
vector4:
  pushl $0
801051fa:	6a 00                	push   $0x0
  pushl $4
801051fc:	6a 04                	push   $0x4
  jmp alltraps
801051fe:	e9 aa fb ff ff       	jmp    80104dad <alltraps>

80105203 <vector5>:
.globl vector5
vector5:
  pushl $0
80105203:	6a 00                	push   $0x0
  pushl $5
80105205:	6a 05                	push   $0x5
  jmp alltraps
80105207:	e9 a1 fb ff ff       	jmp    80104dad <alltraps>

8010520c <vector6>:
.globl vector6
vector6:
  pushl $0
8010520c:	6a 00                	push   $0x0
  pushl $6
8010520e:	6a 06                	push   $0x6
  jmp alltraps
80105210:	e9 98 fb ff ff       	jmp    80104dad <alltraps>

80105215 <vector7>:
.globl vector7
vector7:
  pushl $0
80105215:	6a 00                	push   $0x0
  pushl $7
80105217:	6a 07                	push   $0x7
  jmp alltraps
80105219:	e9 8f fb ff ff       	jmp    80104dad <alltraps>

8010521e <vector8>:
.globl vector8
vector8:
  pushl $8
8010521e:	6a 08                	push   $0x8
  jmp alltraps
80105220:	e9 88 fb ff ff       	jmp    80104dad <alltraps>

80105225 <vector9>:
.globl vector9
vector9:
  pushl $0
80105225:	6a 00                	push   $0x0
  pushl $9
80105227:	6a 09                	push   $0x9
  jmp alltraps
80105229:	e9 7f fb ff ff       	jmp    80104dad <alltraps>

8010522e <vector10>:
.globl vector10
vector10:
  pushl $10
8010522e:	6a 0a                	push   $0xa
  jmp alltraps
80105230:	e9 78 fb ff ff       	jmp    80104dad <alltraps>

80105235 <vector11>:
.globl vector11
vector11:
  pushl $11
80105235:	6a 0b                	push   $0xb
  jmp alltraps
80105237:	e9 71 fb ff ff       	jmp    80104dad <alltraps>

8010523c <vector12>:
.globl vector12
vector12:
  pushl $12
8010523c:	6a 0c                	push   $0xc
  jmp alltraps
8010523e:	e9 6a fb ff ff       	jmp    80104dad <alltraps>

80105243 <vector13>:
.globl vector13
vector13:
  pushl $13
80105243:	6a 0d                	push   $0xd
  jmp alltraps
80105245:	e9 63 fb ff ff       	jmp    80104dad <alltraps>

8010524a <vector14>:
.globl vector14
vector14:
  pushl $14
8010524a:	6a 0e                	push   $0xe
  jmp alltraps
8010524c:	e9 5c fb ff ff       	jmp    80104dad <alltraps>

80105251 <vector15>:
.globl vector15
vector15:
  pushl $0
80105251:	6a 00                	push   $0x0
  pushl $15
80105253:	6a 0f                	push   $0xf
  jmp alltraps
80105255:	e9 53 fb ff ff       	jmp    80104dad <alltraps>

8010525a <vector16>:
.globl vector16
vector16:
  pushl $0
8010525a:	6a 00                	push   $0x0
  pushl $16
8010525c:	6a 10                	push   $0x10
  jmp alltraps
8010525e:	e9 4a fb ff ff       	jmp    80104dad <alltraps>

80105263 <vector17>:
.globl vector17
vector17:
  pushl $17
80105263:	6a 11                	push   $0x11
  jmp alltraps
80105265:	e9 43 fb ff ff       	jmp    80104dad <alltraps>

8010526a <vector18>:
.globl vector18
vector18:
  pushl $0
8010526a:	6a 00                	push   $0x0
  pushl $18
8010526c:	6a 12                	push   $0x12
  jmp alltraps
8010526e:	e9 3a fb ff ff       	jmp    80104dad <alltraps>

80105273 <vector19>:
.globl vector19
vector19:
  pushl $0
80105273:	6a 00                	push   $0x0
  pushl $19
80105275:	6a 13                	push   $0x13
  jmp alltraps
80105277:	e9 31 fb ff ff       	jmp    80104dad <alltraps>

8010527c <vector20>:
.globl vector20
vector20:
  pushl $0
8010527c:	6a 00                	push   $0x0
  pushl $20
8010527e:	6a 14                	push   $0x14
  jmp alltraps
80105280:	e9 28 fb ff ff       	jmp    80104dad <alltraps>

80105285 <vector21>:
.globl vector21
vector21:
  pushl $0
80105285:	6a 00                	push   $0x0
  pushl $21
80105287:	6a 15                	push   $0x15
  jmp alltraps
80105289:	e9 1f fb ff ff       	jmp    80104dad <alltraps>

8010528e <vector22>:
.globl vector22
vector22:
  pushl $0
8010528e:	6a 00                	push   $0x0
  pushl $22
80105290:	6a 16                	push   $0x16
  jmp alltraps
80105292:	e9 16 fb ff ff       	jmp    80104dad <alltraps>

80105297 <vector23>:
.globl vector23
vector23:
  pushl $0
80105297:	6a 00                	push   $0x0
  pushl $23
80105299:	6a 17                	push   $0x17
  jmp alltraps
8010529b:	e9 0d fb ff ff       	jmp    80104dad <alltraps>

801052a0 <vector24>:
.globl vector24
vector24:
  pushl $0
801052a0:	6a 00                	push   $0x0
  pushl $24
801052a2:	6a 18                	push   $0x18
  jmp alltraps
801052a4:	e9 04 fb ff ff       	jmp    80104dad <alltraps>

801052a9 <vector25>:
.globl vector25
vector25:
  pushl $0
801052a9:	6a 00                	push   $0x0
  pushl $25
801052ab:	6a 19                	push   $0x19
  jmp alltraps
801052ad:	e9 fb fa ff ff       	jmp    80104dad <alltraps>

801052b2 <vector26>:
.globl vector26
vector26:
  pushl $0
801052b2:	6a 00                	push   $0x0
  pushl $26
801052b4:	6a 1a                	push   $0x1a
  jmp alltraps
801052b6:	e9 f2 fa ff ff       	jmp    80104dad <alltraps>

801052bb <vector27>:
.globl vector27
vector27:
  pushl $0
801052bb:	6a 00                	push   $0x0
  pushl $27
801052bd:	6a 1b                	push   $0x1b
  jmp alltraps
801052bf:	e9 e9 fa ff ff       	jmp    80104dad <alltraps>

801052c4 <vector28>:
.globl vector28
vector28:
  pushl $0
801052c4:	6a 00                	push   $0x0
  pushl $28
801052c6:	6a 1c                	push   $0x1c
  jmp alltraps
801052c8:	e9 e0 fa ff ff       	jmp    80104dad <alltraps>

801052cd <vector29>:
.globl vector29
vector29:
  pushl $0
801052cd:	6a 00                	push   $0x0
  pushl $29
801052cf:	6a 1d                	push   $0x1d
  jmp alltraps
801052d1:	e9 d7 fa ff ff       	jmp    80104dad <alltraps>

801052d6 <vector30>:
.globl vector30
vector30:
  pushl $0
801052d6:	6a 00                	push   $0x0
  pushl $30
801052d8:	6a 1e                	push   $0x1e
  jmp alltraps
801052da:	e9 ce fa ff ff       	jmp    80104dad <alltraps>

801052df <vector31>:
.globl vector31
vector31:
  pushl $0
801052df:	6a 00                	push   $0x0
  pushl $31
801052e1:	6a 1f                	push   $0x1f
  jmp alltraps
801052e3:	e9 c5 fa ff ff       	jmp    80104dad <alltraps>

801052e8 <vector32>:
.globl vector32
vector32:
  pushl $0
801052e8:	6a 00                	push   $0x0
  pushl $32
801052ea:	6a 20                	push   $0x20
  jmp alltraps
801052ec:	e9 bc fa ff ff       	jmp    80104dad <alltraps>

801052f1 <vector33>:
.globl vector33
vector33:
  pushl $0
801052f1:	6a 00                	push   $0x0
  pushl $33
801052f3:	6a 21                	push   $0x21
  jmp alltraps
801052f5:	e9 b3 fa ff ff       	jmp    80104dad <alltraps>

801052fa <vector34>:
.globl vector34
vector34:
  pushl $0
801052fa:	6a 00                	push   $0x0
  pushl $34
801052fc:	6a 22                	push   $0x22
  jmp alltraps
801052fe:	e9 aa fa ff ff       	jmp    80104dad <alltraps>

80105303 <vector35>:
.globl vector35
vector35:
  pushl $0
80105303:	6a 00                	push   $0x0
  pushl $35
80105305:	6a 23                	push   $0x23
  jmp alltraps
80105307:	e9 a1 fa ff ff       	jmp    80104dad <alltraps>

8010530c <vector36>:
.globl vector36
vector36:
  pushl $0
8010530c:	6a 00                	push   $0x0
  pushl $36
8010530e:	6a 24                	push   $0x24
  jmp alltraps
80105310:	e9 98 fa ff ff       	jmp    80104dad <alltraps>

80105315 <vector37>:
.globl vector37
vector37:
  pushl $0
80105315:	6a 00                	push   $0x0
  pushl $37
80105317:	6a 25                	push   $0x25
  jmp alltraps
80105319:	e9 8f fa ff ff       	jmp    80104dad <alltraps>

8010531e <vector38>:
.globl vector38
vector38:
  pushl $0
8010531e:	6a 00                	push   $0x0
  pushl $38
80105320:	6a 26                	push   $0x26
  jmp alltraps
80105322:	e9 86 fa ff ff       	jmp    80104dad <alltraps>

80105327 <vector39>:
.globl vector39
vector39:
  pushl $0
80105327:	6a 00                	push   $0x0
  pushl $39
80105329:	6a 27                	push   $0x27
  jmp alltraps
8010532b:	e9 7d fa ff ff       	jmp    80104dad <alltraps>

80105330 <vector40>:
.globl vector40
vector40:
  pushl $0
80105330:	6a 00                	push   $0x0
  pushl $40
80105332:	6a 28                	push   $0x28
  jmp alltraps
80105334:	e9 74 fa ff ff       	jmp    80104dad <alltraps>

80105339 <vector41>:
.globl vector41
vector41:
  pushl $0
80105339:	6a 00                	push   $0x0
  pushl $41
8010533b:	6a 29                	push   $0x29
  jmp alltraps
8010533d:	e9 6b fa ff ff       	jmp    80104dad <alltraps>

80105342 <vector42>:
.globl vector42
vector42:
  pushl $0
80105342:	6a 00                	push   $0x0
  pushl $42
80105344:	6a 2a                	push   $0x2a
  jmp alltraps
80105346:	e9 62 fa ff ff       	jmp    80104dad <alltraps>

8010534b <vector43>:
.globl vector43
vector43:
  pushl $0
8010534b:	6a 00                	push   $0x0
  pushl $43
8010534d:	6a 2b                	push   $0x2b
  jmp alltraps
8010534f:	e9 59 fa ff ff       	jmp    80104dad <alltraps>

80105354 <vector44>:
.globl vector44
vector44:
  pushl $0
80105354:	6a 00                	push   $0x0
  pushl $44
80105356:	6a 2c                	push   $0x2c
  jmp alltraps
80105358:	e9 50 fa ff ff       	jmp    80104dad <alltraps>

8010535d <vector45>:
.globl vector45
vector45:
  pushl $0
8010535d:	6a 00                	push   $0x0
  pushl $45
8010535f:	6a 2d                	push   $0x2d
  jmp alltraps
80105361:	e9 47 fa ff ff       	jmp    80104dad <alltraps>

80105366 <vector46>:
.globl vector46
vector46:
  pushl $0
80105366:	6a 00                	push   $0x0
  pushl $46
80105368:	6a 2e                	push   $0x2e
  jmp alltraps
8010536a:	e9 3e fa ff ff       	jmp    80104dad <alltraps>

8010536f <vector47>:
.globl vector47
vector47:
  pushl $0
8010536f:	6a 00                	push   $0x0
  pushl $47
80105371:	6a 2f                	push   $0x2f
  jmp alltraps
80105373:	e9 35 fa ff ff       	jmp    80104dad <alltraps>

80105378 <vector48>:
.globl vector48
vector48:
  pushl $0
80105378:	6a 00                	push   $0x0
  pushl $48
8010537a:	6a 30                	push   $0x30
  jmp alltraps
8010537c:	e9 2c fa ff ff       	jmp    80104dad <alltraps>

80105381 <vector49>:
.globl vector49
vector49:
  pushl $0
80105381:	6a 00                	push   $0x0
  pushl $49
80105383:	6a 31                	push   $0x31
  jmp alltraps
80105385:	e9 23 fa ff ff       	jmp    80104dad <alltraps>

8010538a <vector50>:
.globl vector50
vector50:
  pushl $0
8010538a:	6a 00                	push   $0x0
  pushl $50
8010538c:	6a 32                	push   $0x32
  jmp alltraps
8010538e:	e9 1a fa ff ff       	jmp    80104dad <alltraps>

80105393 <vector51>:
.globl vector51
vector51:
  pushl $0
80105393:	6a 00                	push   $0x0
  pushl $51
80105395:	6a 33                	push   $0x33
  jmp alltraps
80105397:	e9 11 fa ff ff       	jmp    80104dad <alltraps>

8010539c <vector52>:
.globl vector52
vector52:
  pushl $0
8010539c:	6a 00                	push   $0x0
  pushl $52
8010539e:	6a 34                	push   $0x34
  jmp alltraps
801053a0:	e9 08 fa ff ff       	jmp    80104dad <alltraps>

801053a5 <vector53>:
.globl vector53
vector53:
  pushl $0
801053a5:	6a 00                	push   $0x0
  pushl $53
801053a7:	6a 35                	push   $0x35
  jmp alltraps
801053a9:	e9 ff f9 ff ff       	jmp    80104dad <alltraps>

801053ae <vector54>:
.globl vector54
vector54:
  pushl $0
801053ae:	6a 00                	push   $0x0
  pushl $54
801053b0:	6a 36                	push   $0x36
  jmp alltraps
801053b2:	e9 f6 f9 ff ff       	jmp    80104dad <alltraps>

801053b7 <vector55>:
.globl vector55
vector55:
  pushl $0
801053b7:	6a 00                	push   $0x0
  pushl $55
801053b9:	6a 37                	push   $0x37
  jmp alltraps
801053bb:	e9 ed f9 ff ff       	jmp    80104dad <alltraps>

801053c0 <vector56>:
.globl vector56
vector56:
  pushl $0
801053c0:	6a 00                	push   $0x0
  pushl $56
801053c2:	6a 38                	push   $0x38
  jmp alltraps
801053c4:	e9 e4 f9 ff ff       	jmp    80104dad <alltraps>

801053c9 <vector57>:
.globl vector57
vector57:
  pushl $0
801053c9:	6a 00                	push   $0x0
  pushl $57
801053cb:	6a 39                	push   $0x39
  jmp alltraps
801053cd:	e9 db f9 ff ff       	jmp    80104dad <alltraps>

801053d2 <vector58>:
.globl vector58
vector58:
  pushl $0
801053d2:	6a 00                	push   $0x0
  pushl $58
801053d4:	6a 3a                	push   $0x3a
  jmp alltraps
801053d6:	e9 d2 f9 ff ff       	jmp    80104dad <alltraps>

801053db <vector59>:
.globl vector59
vector59:
  pushl $0
801053db:	6a 00                	push   $0x0
  pushl $59
801053dd:	6a 3b                	push   $0x3b
  jmp alltraps
801053df:	e9 c9 f9 ff ff       	jmp    80104dad <alltraps>

801053e4 <vector60>:
.globl vector60
vector60:
  pushl $0
801053e4:	6a 00                	push   $0x0
  pushl $60
801053e6:	6a 3c                	push   $0x3c
  jmp alltraps
801053e8:	e9 c0 f9 ff ff       	jmp    80104dad <alltraps>

801053ed <vector61>:
.globl vector61
vector61:
  pushl $0
801053ed:	6a 00                	push   $0x0
  pushl $61
801053ef:	6a 3d                	push   $0x3d
  jmp alltraps
801053f1:	e9 b7 f9 ff ff       	jmp    80104dad <alltraps>

801053f6 <vector62>:
.globl vector62
vector62:
  pushl $0
801053f6:	6a 00                	push   $0x0
  pushl $62
801053f8:	6a 3e                	push   $0x3e
  jmp alltraps
801053fa:	e9 ae f9 ff ff       	jmp    80104dad <alltraps>

801053ff <vector63>:
.globl vector63
vector63:
  pushl $0
801053ff:	6a 00                	push   $0x0
  pushl $63
80105401:	6a 3f                	push   $0x3f
  jmp alltraps
80105403:	e9 a5 f9 ff ff       	jmp    80104dad <alltraps>

80105408 <vector64>:
.globl vector64
vector64:
  pushl $0
80105408:	6a 00                	push   $0x0
  pushl $64
8010540a:	6a 40                	push   $0x40
  jmp alltraps
8010540c:	e9 9c f9 ff ff       	jmp    80104dad <alltraps>

80105411 <vector65>:
.globl vector65
vector65:
  pushl $0
80105411:	6a 00                	push   $0x0
  pushl $65
80105413:	6a 41                	push   $0x41
  jmp alltraps
80105415:	e9 93 f9 ff ff       	jmp    80104dad <alltraps>

8010541a <vector66>:
.globl vector66
vector66:
  pushl $0
8010541a:	6a 00                	push   $0x0
  pushl $66
8010541c:	6a 42                	push   $0x42
  jmp alltraps
8010541e:	e9 8a f9 ff ff       	jmp    80104dad <alltraps>

80105423 <vector67>:
.globl vector67
vector67:
  pushl $0
80105423:	6a 00                	push   $0x0
  pushl $67
80105425:	6a 43                	push   $0x43
  jmp alltraps
80105427:	e9 81 f9 ff ff       	jmp    80104dad <alltraps>

8010542c <vector68>:
.globl vector68
vector68:
  pushl $0
8010542c:	6a 00                	push   $0x0
  pushl $68
8010542e:	6a 44                	push   $0x44
  jmp alltraps
80105430:	e9 78 f9 ff ff       	jmp    80104dad <alltraps>

80105435 <vector69>:
.globl vector69
vector69:
  pushl $0
80105435:	6a 00                	push   $0x0
  pushl $69
80105437:	6a 45                	push   $0x45
  jmp alltraps
80105439:	e9 6f f9 ff ff       	jmp    80104dad <alltraps>

8010543e <vector70>:
.globl vector70
vector70:
  pushl $0
8010543e:	6a 00                	push   $0x0
  pushl $70
80105440:	6a 46                	push   $0x46
  jmp alltraps
80105442:	e9 66 f9 ff ff       	jmp    80104dad <alltraps>

80105447 <vector71>:
.globl vector71
vector71:
  pushl $0
80105447:	6a 00                	push   $0x0
  pushl $71
80105449:	6a 47                	push   $0x47
  jmp alltraps
8010544b:	e9 5d f9 ff ff       	jmp    80104dad <alltraps>

80105450 <vector72>:
.globl vector72
vector72:
  pushl $0
80105450:	6a 00                	push   $0x0
  pushl $72
80105452:	6a 48                	push   $0x48
  jmp alltraps
80105454:	e9 54 f9 ff ff       	jmp    80104dad <alltraps>

80105459 <vector73>:
.globl vector73
vector73:
  pushl $0
80105459:	6a 00                	push   $0x0
  pushl $73
8010545b:	6a 49                	push   $0x49
  jmp alltraps
8010545d:	e9 4b f9 ff ff       	jmp    80104dad <alltraps>

80105462 <vector74>:
.globl vector74
vector74:
  pushl $0
80105462:	6a 00                	push   $0x0
  pushl $74
80105464:	6a 4a                	push   $0x4a
  jmp alltraps
80105466:	e9 42 f9 ff ff       	jmp    80104dad <alltraps>

8010546b <vector75>:
.globl vector75
vector75:
  pushl $0
8010546b:	6a 00                	push   $0x0
  pushl $75
8010546d:	6a 4b                	push   $0x4b
  jmp alltraps
8010546f:	e9 39 f9 ff ff       	jmp    80104dad <alltraps>

80105474 <vector76>:
.globl vector76
vector76:
  pushl $0
80105474:	6a 00                	push   $0x0
  pushl $76
80105476:	6a 4c                	push   $0x4c
  jmp alltraps
80105478:	e9 30 f9 ff ff       	jmp    80104dad <alltraps>

8010547d <vector77>:
.globl vector77
vector77:
  pushl $0
8010547d:	6a 00                	push   $0x0
  pushl $77
8010547f:	6a 4d                	push   $0x4d
  jmp alltraps
80105481:	e9 27 f9 ff ff       	jmp    80104dad <alltraps>

80105486 <vector78>:
.globl vector78
vector78:
  pushl $0
80105486:	6a 00                	push   $0x0
  pushl $78
80105488:	6a 4e                	push   $0x4e
  jmp alltraps
8010548a:	e9 1e f9 ff ff       	jmp    80104dad <alltraps>

8010548f <vector79>:
.globl vector79
vector79:
  pushl $0
8010548f:	6a 00                	push   $0x0
  pushl $79
80105491:	6a 4f                	push   $0x4f
  jmp alltraps
80105493:	e9 15 f9 ff ff       	jmp    80104dad <alltraps>

80105498 <vector80>:
.globl vector80
vector80:
  pushl $0
80105498:	6a 00                	push   $0x0
  pushl $80
8010549a:	6a 50                	push   $0x50
  jmp alltraps
8010549c:	e9 0c f9 ff ff       	jmp    80104dad <alltraps>

801054a1 <vector81>:
.globl vector81
vector81:
  pushl $0
801054a1:	6a 00                	push   $0x0
  pushl $81
801054a3:	6a 51                	push   $0x51
  jmp alltraps
801054a5:	e9 03 f9 ff ff       	jmp    80104dad <alltraps>

801054aa <vector82>:
.globl vector82
vector82:
  pushl $0
801054aa:	6a 00                	push   $0x0
  pushl $82
801054ac:	6a 52                	push   $0x52
  jmp alltraps
801054ae:	e9 fa f8 ff ff       	jmp    80104dad <alltraps>

801054b3 <vector83>:
.globl vector83
vector83:
  pushl $0
801054b3:	6a 00                	push   $0x0
  pushl $83
801054b5:	6a 53                	push   $0x53
  jmp alltraps
801054b7:	e9 f1 f8 ff ff       	jmp    80104dad <alltraps>

801054bc <vector84>:
.globl vector84
vector84:
  pushl $0
801054bc:	6a 00                	push   $0x0
  pushl $84
801054be:	6a 54                	push   $0x54
  jmp alltraps
801054c0:	e9 e8 f8 ff ff       	jmp    80104dad <alltraps>

801054c5 <vector85>:
.globl vector85
vector85:
  pushl $0
801054c5:	6a 00                	push   $0x0
  pushl $85
801054c7:	6a 55                	push   $0x55
  jmp alltraps
801054c9:	e9 df f8 ff ff       	jmp    80104dad <alltraps>

801054ce <vector86>:
.globl vector86
vector86:
  pushl $0
801054ce:	6a 00                	push   $0x0
  pushl $86
801054d0:	6a 56                	push   $0x56
  jmp alltraps
801054d2:	e9 d6 f8 ff ff       	jmp    80104dad <alltraps>

801054d7 <vector87>:
.globl vector87
vector87:
  pushl $0
801054d7:	6a 00                	push   $0x0
  pushl $87
801054d9:	6a 57                	push   $0x57
  jmp alltraps
801054db:	e9 cd f8 ff ff       	jmp    80104dad <alltraps>

801054e0 <vector88>:
.globl vector88
vector88:
  pushl $0
801054e0:	6a 00                	push   $0x0
  pushl $88
801054e2:	6a 58                	push   $0x58
  jmp alltraps
801054e4:	e9 c4 f8 ff ff       	jmp    80104dad <alltraps>

801054e9 <vector89>:
.globl vector89
vector89:
  pushl $0
801054e9:	6a 00                	push   $0x0
  pushl $89
801054eb:	6a 59                	push   $0x59
  jmp alltraps
801054ed:	e9 bb f8 ff ff       	jmp    80104dad <alltraps>

801054f2 <vector90>:
.globl vector90
vector90:
  pushl $0
801054f2:	6a 00                	push   $0x0
  pushl $90
801054f4:	6a 5a                	push   $0x5a
  jmp alltraps
801054f6:	e9 b2 f8 ff ff       	jmp    80104dad <alltraps>

801054fb <vector91>:
.globl vector91
vector91:
  pushl $0
801054fb:	6a 00                	push   $0x0
  pushl $91
801054fd:	6a 5b                	push   $0x5b
  jmp alltraps
801054ff:	e9 a9 f8 ff ff       	jmp    80104dad <alltraps>

80105504 <vector92>:
.globl vector92
vector92:
  pushl $0
80105504:	6a 00                	push   $0x0
  pushl $92
80105506:	6a 5c                	push   $0x5c
  jmp alltraps
80105508:	e9 a0 f8 ff ff       	jmp    80104dad <alltraps>

8010550d <vector93>:
.globl vector93
vector93:
  pushl $0
8010550d:	6a 00                	push   $0x0
  pushl $93
8010550f:	6a 5d                	push   $0x5d
  jmp alltraps
80105511:	e9 97 f8 ff ff       	jmp    80104dad <alltraps>

80105516 <vector94>:
.globl vector94
vector94:
  pushl $0
80105516:	6a 00                	push   $0x0
  pushl $94
80105518:	6a 5e                	push   $0x5e
  jmp alltraps
8010551a:	e9 8e f8 ff ff       	jmp    80104dad <alltraps>

8010551f <vector95>:
.globl vector95
vector95:
  pushl $0
8010551f:	6a 00                	push   $0x0
  pushl $95
80105521:	6a 5f                	push   $0x5f
  jmp alltraps
80105523:	e9 85 f8 ff ff       	jmp    80104dad <alltraps>

80105528 <vector96>:
.globl vector96
vector96:
  pushl $0
80105528:	6a 00                	push   $0x0
  pushl $96
8010552a:	6a 60                	push   $0x60
  jmp alltraps
8010552c:	e9 7c f8 ff ff       	jmp    80104dad <alltraps>

80105531 <vector97>:
.globl vector97
vector97:
  pushl $0
80105531:	6a 00                	push   $0x0
  pushl $97
80105533:	6a 61                	push   $0x61
  jmp alltraps
80105535:	e9 73 f8 ff ff       	jmp    80104dad <alltraps>

8010553a <vector98>:
.globl vector98
vector98:
  pushl $0
8010553a:	6a 00                	push   $0x0
  pushl $98
8010553c:	6a 62                	push   $0x62
  jmp alltraps
8010553e:	e9 6a f8 ff ff       	jmp    80104dad <alltraps>

80105543 <vector99>:
.globl vector99
vector99:
  pushl $0
80105543:	6a 00                	push   $0x0
  pushl $99
80105545:	6a 63                	push   $0x63
  jmp alltraps
80105547:	e9 61 f8 ff ff       	jmp    80104dad <alltraps>

8010554c <vector100>:
.globl vector100
vector100:
  pushl $0
8010554c:	6a 00                	push   $0x0
  pushl $100
8010554e:	6a 64                	push   $0x64
  jmp alltraps
80105550:	e9 58 f8 ff ff       	jmp    80104dad <alltraps>

80105555 <vector101>:
.globl vector101
vector101:
  pushl $0
80105555:	6a 00                	push   $0x0
  pushl $101
80105557:	6a 65                	push   $0x65
  jmp alltraps
80105559:	e9 4f f8 ff ff       	jmp    80104dad <alltraps>

8010555e <vector102>:
.globl vector102
vector102:
  pushl $0
8010555e:	6a 00                	push   $0x0
  pushl $102
80105560:	6a 66                	push   $0x66
  jmp alltraps
80105562:	e9 46 f8 ff ff       	jmp    80104dad <alltraps>

80105567 <vector103>:
.globl vector103
vector103:
  pushl $0
80105567:	6a 00                	push   $0x0
  pushl $103
80105569:	6a 67                	push   $0x67
  jmp alltraps
8010556b:	e9 3d f8 ff ff       	jmp    80104dad <alltraps>

80105570 <vector104>:
.globl vector104
vector104:
  pushl $0
80105570:	6a 00                	push   $0x0
  pushl $104
80105572:	6a 68                	push   $0x68
  jmp alltraps
80105574:	e9 34 f8 ff ff       	jmp    80104dad <alltraps>

80105579 <vector105>:
.globl vector105
vector105:
  pushl $0
80105579:	6a 00                	push   $0x0
  pushl $105
8010557b:	6a 69                	push   $0x69
  jmp alltraps
8010557d:	e9 2b f8 ff ff       	jmp    80104dad <alltraps>

80105582 <vector106>:
.globl vector106
vector106:
  pushl $0
80105582:	6a 00                	push   $0x0
  pushl $106
80105584:	6a 6a                	push   $0x6a
  jmp alltraps
80105586:	e9 22 f8 ff ff       	jmp    80104dad <alltraps>

8010558b <vector107>:
.globl vector107
vector107:
  pushl $0
8010558b:	6a 00                	push   $0x0
  pushl $107
8010558d:	6a 6b                	push   $0x6b
  jmp alltraps
8010558f:	e9 19 f8 ff ff       	jmp    80104dad <alltraps>

80105594 <vector108>:
.globl vector108
vector108:
  pushl $0
80105594:	6a 00                	push   $0x0
  pushl $108
80105596:	6a 6c                	push   $0x6c
  jmp alltraps
80105598:	e9 10 f8 ff ff       	jmp    80104dad <alltraps>

8010559d <vector109>:
.globl vector109
vector109:
  pushl $0
8010559d:	6a 00                	push   $0x0
  pushl $109
8010559f:	6a 6d                	push   $0x6d
  jmp alltraps
801055a1:	e9 07 f8 ff ff       	jmp    80104dad <alltraps>

801055a6 <vector110>:
.globl vector110
vector110:
  pushl $0
801055a6:	6a 00                	push   $0x0
  pushl $110
801055a8:	6a 6e                	push   $0x6e
  jmp alltraps
801055aa:	e9 fe f7 ff ff       	jmp    80104dad <alltraps>

801055af <vector111>:
.globl vector111
vector111:
  pushl $0
801055af:	6a 00                	push   $0x0
  pushl $111
801055b1:	6a 6f                	push   $0x6f
  jmp alltraps
801055b3:	e9 f5 f7 ff ff       	jmp    80104dad <alltraps>

801055b8 <vector112>:
.globl vector112
vector112:
  pushl $0
801055b8:	6a 00                	push   $0x0
  pushl $112
801055ba:	6a 70                	push   $0x70
  jmp alltraps
801055bc:	e9 ec f7 ff ff       	jmp    80104dad <alltraps>

801055c1 <vector113>:
.globl vector113
vector113:
  pushl $0
801055c1:	6a 00                	push   $0x0
  pushl $113
801055c3:	6a 71                	push   $0x71
  jmp alltraps
801055c5:	e9 e3 f7 ff ff       	jmp    80104dad <alltraps>

801055ca <vector114>:
.globl vector114
vector114:
  pushl $0
801055ca:	6a 00                	push   $0x0
  pushl $114
801055cc:	6a 72                	push   $0x72
  jmp alltraps
801055ce:	e9 da f7 ff ff       	jmp    80104dad <alltraps>

801055d3 <vector115>:
.globl vector115
vector115:
  pushl $0
801055d3:	6a 00                	push   $0x0
  pushl $115
801055d5:	6a 73                	push   $0x73
  jmp alltraps
801055d7:	e9 d1 f7 ff ff       	jmp    80104dad <alltraps>

801055dc <vector116>:
.globl vector116
vector116:
  pushl $0
801055dc:	6a 00                	push   $0x0
  pushl $116
801055de:	6a 74                	push   $0x74
  jmp alltraps
801055e0:	e9 c8 f7 ff ff       	jmp    80104dad <alltraps>

801055e5 <vector117>:
.globl vector117
vector117:
  pushl $0
801055e5:	6a 00                	push   $0x0
  pushl $117
801055e7:	6a 75                	push   $0x75
  jmp alltraps
801055e9:	e9 bf f7 ff ff       	jmp    80104dad <alltraps>

801055ee <vector118>:
.globl vector118
vector118:
  pushl $0
801055ee:	6a 00                	push   $0x0
  pushl $118
801055f0:	6a 76                	push   $0x76
  jmp alltraps
801055f2:	e9 b6 f7 ff ff       	jmp    80104dad <alltraps>

801055f7 <vector119>:
.globl vector119
vector119:
  pushl $0
801055f7:	6a 00                	push   $0x0
  pushl $119
801055f9:	6a 77                	push   $0x77
  jmp alltraps
801055fb:	e9 ad f7 ff ff       	jmp    80104dad <alltraps>

80105600 <vector120>:
.globl vector120
vector120:
  pushl $0
80105600:	6a 00                	push   $0x0
  pushl $120
80105602:	6a 78                	push   $0x78
  jmp alltraps
80105604:	e9 a4 f7 ff ff       	jmp    80104dad <alltraps>

80105609 <vector121>:
.globl vector121
vector121:
  pushl $0
80105609:	6a 00                	push   $0x0
  pushl $121
8010560b:	6a 79                	push   $0x79
  jmp alltraps
8010560d:	e9 9b f7 ff ff       	jmp    80104dad <alltraps>

80105612 <vector122>:
.globl vector122
vector122:
  pushl $0
80105612:	6a 00                	push   $0x0
  pushl $122
80105614:	6a 7a                	push   $0x7a
  jmp alltraps
80105616:	e9 92 f7 ff ff       	jmp    80104dad <alltraps>

8010561b <vector123>:
.globl vector123
vector123:
  pushl $0
8010561b:	6a 00                	push   $0x0
  pushl $123
8010561d:	6a 7b                	push   $0x7b
  jmp alltraps
8010561f:	e9 89 f7 ff ff       	jmp    80104dad <alltraps>

80105624 <vector124>:
.globl vector124
vector124:
  pushl $0
80105624:	6a 00                	push   $0x0
  pushl $124
80105626:	6a 7c                	push   $0x7c
  jmp alltraps
80105628:	e9 80 f7 ff ff       	jmp    80104dad <alltraps>

8010562d <vector125>:
.globl vector125
vector125:
  pushl $0
8010562d:	6a 00                	push   $0x0
  pushl $125
8010562f:	6a 7d                	push   $0x7d
  jmp alltraps
80105631:	e9 77 f7 ff ff       	jmp    80104dad <alltraps>

80105636 <vector126>:
.globl vector126
vector126:
  pushl $0
80105636:	6a 00                	push   $0x0
  pushl $126
80105638:	6a 7e                	push   $0x7e
  jmp alltraps
8010563a:	e9 6e f7 ff ff       	jmp    80104dad <alltraps>

8010563f <vector127>:
.globl vector127
vector127:
  pushl $0
8010563f:	6a 00                	push   $0x0
  pushl $127
80105641:	6a 7f                	push   $0x7f
  jmp alltraps
80105643:	e9 65 f7 ff ff       	jmp    80104dad <alltraps>

80105648 <vector128>:
.globl vector128
vector128:
  pushl $0
80105648:	6a 00                	push   $0x0
  pushl $128
8010564a:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010564f:	e9 59 f7 ff ff       	jmp    80104dad <alltraps>

80105654 <vector129>:
.globl vector129
vector129:
  pushl $0
80105654:	6a 00                	push   $0x0
  pushl $129
80105656:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010565b:	e9 4d f7 ff ff       	jmp    80104dad <alltraps>

80105660 <vector130>:
.globl vector130
vector130:
  pushl $0
80105660:	6a 00                	push   $0x0
  pushl $130
80105662:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80105667:	e9 41 f7 ff ff       	jmp    80104dad <alltraps>

8010566c <vector131>:
.globl vector131
vector131:
  pushl $0
8010566c:	6a 00                	push   $0x0
  pushl $131
8010566e:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80105673:	e9 35 f7 ff ff       	jmp    80104dad <alltraps>

80105678 <vector132>:
.globl vector132
vector132:
  pushl $0
80105678:	6a 00                	push   $0x0
  pushl $132
8010567a:	68 84 00 00 00       	push   $0x84
  jmp alltraps
8010567f:	e9 29 f7 ff ff       	jmp    80104dad <alltraps>

80105684 <vector133>:
.globl vector133
vector133:
  pushl $0
80105684:	6a 00                	push   $0x0
  pushl $133
80105686:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010568b:	e9 1d f7 ff ff       	jmp    80104dad <alltraps>

80105690 <vector134>:
.globl vector134
vector134:
  pushl $0
80105690:	6a 00                	push   $0x0
  pushl $134
80105692:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80105697:	e9 11 f7 ff ff       	jmp    80104dad <alltraps>

8010569c <vector135>:
.globl vector135
vector135:
  pushl $0
8010569c:	6a 00                	push   $0x0
  pushl $135
8010569e:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801056a3:	e9 05 f7 ff ff       	jmp    80104dad <alltraps>

801056a8 <vector136>:
.globl vector136
vector136:
  pushl $0
801056a8:	6a 00                	push   $0x0
  pushl $136
801056aa:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801056af:	e9 f9 f6 ff ff       	jmp    80104dad <alltraps>

801056b4 <vector137>:
.globl vector137
vector137:
  pushl $0
801056b4:	6a 00                	push   $0x0
  pushl $137
801056b6:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801056bb:	e9 ed f6 ff ff       	jmp    80104dad <alltraps>

801056c0 <vector138>:
.globl vector138
vector138:
  pushl $0
801056c0:	6a 00                	push   $0x0
  pushl $138
801056c2:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801056c7:	e9 e1 f6 ff ff       	jmp    80104dad <alltraps>

801056cc <vector139>:
.globl vector139
vector139:
  pushl $0
801056cc:	6a 00                	push   $0x0
  pushl $139
801056ce:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801056d3:	e9 d5 f6 ff ff       	jmp    80104dad <alltraps>

801056d8 <vector140>:
.globl vector140
vector140:
  pushl $0
801056d8:	6a 00                	push   $0x0
  pushl $140
801056da:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801056df:	e9 c9 f6 ff ff       	jmp    80104dad <alltraps>

801056e4 <vector141>:
.globl vector141
vector141:
  pushl $0
801056e4:	6a 00                	push   $0x0
  pushl $141
801056e6:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801056eb:	e9 bd f6 ff ff       	jmp    80104dad <alltraps>

801056f0 <vector142>:
.globl vector142
vector142:
  pushl $0
801056f0:	6a 00                	push   $0x0
  pushl $142
801056f2:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801056f7:	e9 b1 f6 ff ff       	jmp    80104dad <alltraps>

801056fc <vector143>:
.globl vector143
vector143:
  pushl $0
801056fc:	6a 00                	push   $0x0
  pushl $143
801056fe:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80105703:	e9 a5 f6 ff ff       	jmp    80104dad <alltraps>

80105708 <vector144>:
.globl vector144
vector144:
  pushl $0
80105708:	6a 00                	push   $0x0
  pushl $144
8010570a:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010570f:	e9 99 f6 ff ff       	jmp    80104dad <alltraps>

80105714 <vector145>:
.globl vector145
vector145:
  pushl $0
80105714:	6a 00                	push   $0x0
  pushl $145
80105716:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010571b:	e9 8d f6 ff ff       	jmp    80104dad <alltraps>

80105720 <vector146>:
.globl vector146
vector146:
  pushl $0
80105720:	6a 00                	push   $0x0
  pushl $146
80105722:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80105727:	e9 81 f6 ff ff       	jmp    80104dad <alltraps>

8010572c <vector147>:
.globl vector147
vector147:
  pushl $0
8010572c:	6a 00                	push   $0x0
  pushl $147
8010572e:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80105733:	e9 75 f6 ff ff       	jmp    80104dad <alltraps>

80105738 <vector148>:
.globl vector148
vector148:
  pushl $0
80105738:	6a 00                	push   $0x0
  pushl $148
8010573a:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010573f:	e9 69 f6 ff ff       	jmp    80104dad <alltraps>

80105744 <vector149>:
.globl vector149
vector149:
  pushl $0
80105744:	6a 00                	push   $0x0
  pushl $149
80105746:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010574b:	e9 5d f6 ff ff       	jmp    80104dad <alltraps>

80105750 <vector150>:
.globl vector150
vector150:
  pushl $0
80105750:	6a 00                	push   $0x0
  pushl $150
80105752:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80105757:	e9 51 f6 ff ff       	jmp    80104dad <alltraps>

8010575c <vector151>:
.globl vector151
vector151:
  pushl $0
8010575c:	6a 00                	push   $0x0
  pushl $151
8010575e:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80105763:	e9 45 f6 ff ff       	jmp    80104dad <alltraps>

80105768 <vector152>:
.globl vector152
vector152:
  pushl $0
80105768:	6a 00                	push   $0x0
  pushl $152
8010576a:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010576f:	e9 39 f6 ff ff       	jmp    80104dad <alltraps>

80105774 <vector153>:
.globl vector153
vector153:
  pushl $0
80105774:	6a 00                	push   $0x0
  pushl $153
80105776:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010577b:	e9 2d f6 ff ff       	jmp    80104dad <alltraps>

80105780 <vector154>:
.globl vector154
vector154:
  pushl $0
80105780:	6a 00                	push   $0x0
  pushl $154
80105782:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80105787:	e9 21 f6 ff ff       	jmp    80104dad <alltraps>

8010578c <vector155>:
.globl vector155
vector155:
  pushl $0
8010578c:	6a 00                	push   $0x0
  pushl $155
8010578e:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80105793:	e9 15 f6 ff ff       	jmp    80104dad <alltraps>

80105798 <vector156>:
.globl vector156
vector156:
  pushl $0
80105798:	6a 00                	push   $0x0
  pushl $156
8010579a:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
8010579f:	e9 09 f6 ff ff       	jmp    80104dad <alltraps>

801057a4 <vector157>:
.globl vector157
vector157:
  pushl $0
801057a4:	6a 00                	push   $0x0
  pushl $157
801057a6:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801057ab:	e9 fd f5 ff ff       	jmp    80104dad <alltraps>

801057b0 <vector158>:
.globl vector158
vector158:
  pushl $0
801057b0:	6a 00                	push   $0x0
  pushl $158
801057b2:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801057b7:	e9 f1 f5 ff ff       	jmp    80104dad <alltraps>

801057bc <vector159>:
.globl vector159
vector159:
  pushl $0
801057bc:	6a 00                	push   $0x0
  pushl $159
801057be:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801057c3:	e9 e5 f5 ff ff       	jmp    80104dad <alltraps>

801057c8 <vector160>:
.globl vector160
vector160:
  pushl $0
801057c8:	6a 00                	push   $0x0
  pushl $160
801057ca:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801057cf:	e9 d9 f5 ff ff       	jmp    80104dad <alltraps>

801057d4 <vector161>:
.globl vector161
vector161:
  pushl $0
801057d4:	6a 00                	push   $0x0
  pushl $161
801057d6:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801057db:	e9 cd f5 ff ff       	jmp    80104dad <alltraps>

801057e0 <vector162>:
.globl vector162
vector162:
  pushl $0
801057e0:	6a 00                	push   $0x0
  pushl $162
801057e2:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801057e7:	e9 c1 f5 ff ff       	jmp    80104dad <alltraps>

801057ec <vector163>:
.globl vector163
vector163:
  pushl $0
801057ec:	6a 00                	push   $0x0
  pushl $163
801057ee:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801057f3:	e9 b5 f5 ff ff       	jmp    80104dad <alltraps>

801057f8 <vector164>:
.globl vector164
vector164:
  pushl $0
801057f8:	6a 00                	push   $0x0
  pushl $164
801057fa:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801057ff:	e9 a9 f5 ff ff       	jmp    80104dad <alltraps>

80105804 <vector165>:
.globl vector165
vector165:
  pushl $0
80105804:	6a 00                	push   $0x0
  pushl $165
80105806:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010580b:	e9 9d f5 ff ff       	jmp    80104dad <alltraps>

80105810 <vector166>:
.globl vector166
vector166:
  pushl $0
80105810:	6a 00                	push   $0x0
  pushl $166
80105812:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80105817:	e9 91 f5 ff ff       	jmp    80104dad <alltraps>

8010581c <vector167>:
.globl vector167
vector167:
  pushl $0
8010581c:	6a 00                	push   $0x0
  pushl $167
8010581e:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80105823:	e9 85 f5 ff ff       	jmp    80104dad <alltraps>

80105828 <vector168>:
.globl vector168
vector168:
  pushl $0
80105828:	6a 00                	push   $0x0
  pushl $168
8010582a:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010582f:	e9 79 f5 ff ff       	jmp    80104dad <alltraps>

80105834 <vector169>:
.globl vector169
vector169:
  pushl $0
80105834:	6a 00                	push   $0x0
  pushl $169
80105836:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010583b:	e9 6d f5 ff ff       	jmp    80104dad <alltraps>

80105840 <vector170>:
.globl vector170
vector170:
  pushl $0
80105840:	6a 00                	push   $0x0
  pushl $170
80105842:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80105847:	e9 61 f5 ff ff       	jmp    80104dad <alltraps>

8010584c <vector171>:
.globl vector171
vector171:
  pushl $0
8010584c:	6a 00                	push   $0x0
  pushl $171
8010584e:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80105853:	e9 55 f5 ff ff       	jmp    80104dad <alltraps>

80105858 <vector172>:
.globl vector172
vector172:
  pushl $0
80105858:	6a 00                	push   $0x0
  pushl $172
8010585a:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010585f:	e9 49 f5 ff ff       	jmp    80104dad <alltraps>

80105864 <vector173>:
.globl vector173
vector173:
  pushl $0
80105864:	6a 00                	push   $0x0
  pushl $173
80105866:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010586b:	e9 3d f5 ff ff       	jmp    80104dad <alltraps>

80105870 <vector174>:
.globl vector174
vector174:
  pushl $0
80105870:	6a 00                	push   $0x0
  pushl $174
80105872:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80105877:	e9 31 f5 ff ff       	jmp    80104dad <alltraps>

8010587c <vector175>:
.globl vector175
vector175:
  pushl $0
8010587c:	6a 00                	push   $0x0
  pushl $175
8010587e:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80105883:	e9 25 f5 ff ff       	jmp    80104dad <alltraps>

80105888 <vector176>:
.globl vector176
vector176:
  pushl $0
80105888:	6a 00                	push   $0x0
  pushl $176
8010588a:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
8010588f:	e9 19 f5 ff ff       	jmp    80104dad <alltraps>

80105894 <vector177>:
.globl vector177
vector177:
  pushl $0
80105894:	6a 00                	push   $0x0
  pushl $177
80105896:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
8010589b:	e9 0d f5 ff ff       	jmp    80104dad <alltraps>

801058a0 <vector178>:
.globl vector178
vector178:
  pushl $0
801058a0:	6a 00                	push   $0x0
  pushl $178
801058a2:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801058a7:	e9 01 f5 ff ff       	jmp    80104dad <alltraps>

801058ac <vector179>:
.globl vector179
vector179:
  pushl $0
801058ac:	6a 00                	push   $0x0
  pushl $179
801058ae:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801058b3:	e9 f5 f4 ff ff       	jmp    80104dad <alltraps>

801058b8 <vector180>:
.globl vector180
vector180:
  pushl $0
801058b8:	6a 00                	push   $0x0
  pushl $180
801058ba:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801058bf:	e9 e9 f4 ff ff       	jmp    80104dad <alltraps>

801058c4 <vector181>:
.globl vector181
vector181:
  pushl $0
801058c4:	6a 00                	push   $0x0
  pushl $181
801058c6:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801058cb:	e9 dd f4 ff ff       	jmp    80104dad <alltraps>

801058d0 <vector182>:
.globl vector182
vector182:
  pushl $0
801058d0:	6a 00                	push   $0x0
  pushl $182
801058d2:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801058d7:	e9 d1 f4 ff ff       	jmp    80104dad <alltraps>

801058dc <vector183>:
.globl vector183
vector183:
  pushl $0
801058dc:	6a 00                	push   $0x0
  pushl $183
801058de:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801058e3:	e9 c5 f4 ff ff       	jmp    80104dad <alltraps>

801058e8 <vector184>:
.globl vector184
vector184:
  pushl $0
801058e8:	6a 00                	push   $0x0
  pushl $184
801058ea:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801058ef:	e9 b9 f4 ff ff       	jmp    80104dad <alltraps>

801058f4 <vector185>:
.globl vector185
vector185:
  pushl $0
801058f4:	6a 00                	push   $0x0
  pushl $185
801058f6:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801058fb:	e9 ad f4 ff ff       	jmp    80104dad <alltraps>

80105900 <vector186>:
.globl vector186
vector186:
  pushl $0
80105900:	6a 00                	push   $0x0
  pushl $186
80105902:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80105907:	e9 a1 f4 ff ff       	jmp    80104dad <alltraps>

8010590c <vector187>:
.globl vector187
vector187:
  pushl $0
8010590c:	6a 00                	push   $0x0
  pushl $187
8010590e:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80105913:	e9 95 f4 ff ff       	jmp    80104dad <alltraps>

80105918 <vector188>:
.globl vector188
vector188:
  pushl $0
80105918:	6a 00                	push   $0x0
  pushl $188
8010591a:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010591f:	e9 89 f4 ff ff       	jmp    80104dad <alltraps>

80105924 <vector189>:
.globl vector189
vector189:
  pushl $0
80105924:	6a 00                	push   $0x0
  pushl $189
80105926:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010592b:	e9 7d f4 ff ff       	jmp    80104dad <alltraps>

80105930 <vector190>:
.globl vector190
vector190:
  pushl $0
80105930:	6a 00                	push   $0x0
  pushl $190
80105932:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80105937:	e9 71 f4 ff ff       	jmp    80104dad <alltraps>

8010593c <vector191>:
.globl vector191
vector191:
  pushl $0
8010593c:	6a 00                	push   $0x0
  pushl $191
8010593e:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80105943:	e9 65 f4 ff ff       	jmp    80104dad <alltraps>

80105948 <vector192>:
.globl vector192
vector192:
  pushl $0
80105948:	6a 00                	push   $0x0
  pushl $192
8010594a:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010594f:	e9 59 f4 ff ff       	jmp    80104dad <alltraps>

80105954 <vector193>:
.globl vector193
vector193:
  pushl $0
80105954:	6a 00                	push   $0x0
  pushl $193
80105956:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010595b:	e9 4d f4 ff ff       	jmp    80104dad <alltraps>

80105960 <vector194>:
.globl vector194
vector194:
  pushl $0
80105960:	6a 00                	push   $0x0
  pushl $194
80105962:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80105967:	e9 41 f4 ff ff       	jmp    80104dad <alltraps>

8010596c <vector195>:
.globl vector195
vector195:
  pushl $0
8010596c:	6a 00                	push   $0x0
  pushl $195
8010596e:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80105973:	e9 35 f4 ff ff       	jmp    80104dad <alltraps>

80105978 <vector196>:
.globl vector196
vector196:
  pushl $0
80105978:	6a 00                	push   $0x0
  pushl $196
8010597a:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010597f:	e9 29 f4 ff ff       	jmp    80104dad <alltraps>

80105984 <vector197>:
.globl vector197
vector197:
  pushl $0
80105984:	6a 00                	push   $0x0
  pushl $197
80105986:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010598b:	e9 1d f4 ff ff       	jmp    80104dad <alltraps>

80105990 <vector198>:
.globl vector198
vector198:
  pushl $0
80105990:	6a 00                	push   $0x0
  pushl $198
80105992:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80105997:	e9 11 f4 ff ff       	jmp    80104dad <alltraps>

8010599c <vector199>:
.globl vector199
vector199:
  pushl $0
8010599c:	6a 00                	push   $0x0
  pushl $199
8010599e:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801059a3:	e9 05 f4 ff ff       	jmp    80104dad <alltraps>

801059a8 <vector200>:
.globl vector200
vector200:
  pushl $0
801059a8:	6a 00                	push   $0x0
  pushl $200
801059aa:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801059af:	e9 f9 f3 ff ff       	jmp    80104dad <alltraps>

801059b4 <vector201>:
.globl vector201
vector201:
  pushl $0
801059b4:	6a 00                	push   $0x0
  pushl $201
801059b6:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801059bb:	e9 ed f3 ff ff       	jmp    80104dad <alltraps>

801059c0 <vector202>:
.globl vector202
vector202:
  pushl $0
801059c0:	6a 00                	push   $0x0
  pushl $202
801059c2:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801059c7:	e9 e1 f3 ff ff       	jmp    80104dad <alltraps>

801059cc <vector203>:
.globl vector203
vector203:
  pushl $0
801059cc:	6a 00                	push   $0x0
  pushl $203
801059ce:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801059d3:	e9 d5 f3 ff ff       	jmp    80104dad <alltraps>

801059d8 <vector204>:
.globl vector204
vector204:
  pushl $0
801059d8:	6a 00                	push   $0x0
  pushl $204
801059da:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801059df:	e9 c9 f3 ff ff       	jmp    80104dad <alltraps>

801059e4 <vector205>:
.globl vector205
vector205:
  pushl $0
801059e4:	6a 00                	push   $0x0
  pushl $205
801059e6:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801059eb:	e9 bd f3 ff ff       	jmp    80104dad <alltraps>

801059f0 <vector206>:
.globl vector206
vector206:
  pushl $0
801059f0:	6a 00                	push   $0x0
  pushl $206
801059f2:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801059f7:	e9 b1 f3 ff ff       	jmp    80104dad <alltraps>

801059fc <vector207>:
.globl vector207
vector207:
  pushl $0
801059fc:	6a 00                	push   $0x0
  pushl $207
801059fe:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80105a03:	e9 a5 f3 ff ff       	jmp    80104dad <alltraps>

80105a08 <vector208>:
.globl vector208
vector208:
  pushl $0
80105a08:	6a 00                	push   $0x0
  pushl $208
80105a0a:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80105a0f:	e9 99 f3 ff ff       	jmp    80104dad <alltraps>

80105a14 <vector209>:
.globl vector209
vector209:
  pushl $0
80105a14:	6a 00                	push   $0x0
  pushl $209
80105a16:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80105a1b:	e9 8d f3 ff ff       	jmp    80104dad <alltraps>

80105a20 <vector210>:
.globl vector210
vector210:
  pushl $0
80105a20:	6a 00                	push   $0x0
  pushl $210
80105a22:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80105a27:	e9 81 f3 ff ff       	jmp    80104dad <alltraps>

80105a2c <vector211>:
.globl vector211
vector211:
  pushl $0
80105a2c:	6a 00                	push   $0x0
  pushl $211
80105a2e:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80105a33:	e9 75 f3 ff ff       	jmp    80104dad <alltraps>

80105a38 <vector212>:
.globl vector212
vector212:
  pushl $0
80105a38:	6a 00                	push   $0x0
  pushl $212
80105a3a:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80105a3f:	e9 69 f3 ff ff       	jmp    80104dad <alltraps>

80105a44 <vector213>:
.globl vector213
vector213:
  pushl $0
80105a44:	6a 00                	push   $0x0
  pushl $213
80105a46:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80105a4b:	e9 5d f3 ff ff       	jmp    80104dad <alltraps>

80105a50 <vector214>:
.globl vector214
vector214:
  pushl $0
80105a50:	6a 00                	push   $0x0
  pushl $214
80105a52:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80105a57:	e9 51 f3 ff ff       	jmp    80104dad <alltraps>

80105a5c <vector215>:
.globl vector215
vector215:
  pushl $0
80105a5c:	6a 00                	push   $0x0
  pushl $215
80105a5e:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80105a63:	e9 45 f3 ff ff       	jmp    80104dad <alltraps>

80105a68 <vector216>:
.globl vector216
vector216:
  pushl $0
80105a68:	6a 00                	push   $0x0
  pushl $216
80105a6a:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80105a6f:	e9 39 f3 ff ff       	jmp    80104dad <alltraps>

80105a74 <vector217>:
.globl vector217
vector217:
  pushl $0
80105a74:	6a 00                	push   $0x0
  pushl $217
80105a76:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80105a7b:	e9 2d f3 ff ff       	jmp    80104dad <alltraps>

80105a80 <vector218>:
.globl vector218
vector218:
  pushl $0
80105a80:	6a 00                	push   $0x0
  pushl $218
80105a82:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80105a87:	e9 21 f3 ff ff       	jmp    80104dad <alltraps>

80105a8c <vector219>:
.globl vector219
vector219:
  pushl $0
80105a8c:	6a 00                	push   $0x0
  pushl $219
80105a8e:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80105a93:	e9 15 f3 ff ff       	jmp    80104dad <alltraps>

80105a98 <vector220>:
.globl vector220
vector220:
  pushl $0
80105a98:	6a 00                	push   $0x0
  pushl $220
80105a9a:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80105a9f:	e9 09 f3 ff ff       	jmp    80104dad <alltraps>

80105aa4 <vector221>:
.globl vector221
vector221:
  pushl $0
80105aa4:	6a 00                	push   $0x0
  pushl $221
80105aa6:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80105aab:	e9 fd f2 ff ff       	jmp    80104dad <alltraps>

80105ab0 <vector222>:
.globl vector222
vector222:
  pushl $0
80105ab0:	6a 00                	push   $0x0
  pushl $222
80105ab2:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80105ab7:	e9 f1 f2 ff ff       	jmp    80104dad <alltraps>

80105abc <vector223>:
.globl vector223
vector223:
  pushl $0
80105abc:	6a 00                	push   $0x0
  pushl $223
80105abe:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80105ac3:	e9 e5 f2 ff ff       	jmp    80104dad <alltraps>

80105ac8 <vector224>:
.globl vector224
vector224:
  pushl $0
80105ac8:	6a 00                	push   $0x0
  pushl $224
80105aca:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80105acf:	e9 d9 f2 ff ff       	jmp    80104dad <alltraps>

80105ad4 <vector225>:
.globl vector225
vector225:
  pushl $0
80105ad4:	6a 00                	push   $0x0
  pushl $225
80105ad6:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80105adb:	e9 cd f2 ff ff       	jmp    80104dad <alltraps>

80105ae0 <vector226>:
.globl vector226
vector226:
  pushl $0
80105ae0:	6a 00                	push   $0x0
  pushl $226
80105ae2:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80105ae7:	e9 c1 f2 ff ff       	jmp    80104dad <alltraps>

80105aec <vector227>:
.globl vector227
vector227:
  pushl $0
80105aec:	6a 00                	push   $0x0
  pushl $227
80105aee:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80105af3:	e9 b5 f2 ff ff       	jmp    80104dad <alltraps>

80105af8 <vector228>:
.globl vector228
vector228:
  pushl $0
80105af8:	6a 00                	push   $0x0
  pushl $228
80105afa:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80105aff:	e9 a9 f2 ff ff       	jmp    80104dad <alltraps>

80105b04 <vector229>:
.globl vector229
vector229:
  pushl $0
80105b04:	6a 00                	push   $0x0
  pushl $229
80105b06:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80105b0b:	e9 9d f2 ff ff       	jmp    80104dad <alltraps>

80105b10 <vector230>:
.globl vector230
vector230:
  pushl $0
80105b10:	6a 00                	push   $0x0
  pushl $230
80105b12:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80105b17:	e9 91 f2 ff ff       	jmp    80104dad <alltraps>

80105b1c <vector231>:
.globl vector231
vector231:
  pushl $0
80105b1c:	6a 00                	push   $0x0
  pushl $231
80105b1e:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80105b23:	e9 85 f2 ff ff       	jmp    80104dad <alltraps>

80105b28 <vector232>:
.globl vector232
vector232:
  pushl $0
80105b28:	6a 00                	push   $0x0
  pushl $232
80105b2a:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80105b2f:	e9 79 f2 ff ff       	jmp    80104dad <alltraps>

80105b34 <vector233>:
.globl vector233
vector233:
  pushl $0
80105b34:	6a 00                	push   $0x0
  pushl $233
80105b36:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80105b3b:	e9 6d f2 ff ff       	jmp    80104dad <alltraps>

80105b40 <vector234>:
.globl vector234
vector234:
  pushl $0
80105b40:	6a 00                	push   $0x0
  pushl $234
80105b42:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80105b47:	e9 61 f2 ff ff       	jmp    80104dad <alltraps>

80105b4c <vector235>:
.globl vector235
vector235:
  pushl $0
80105b4c:	6a 00                	push   $0x0
  pushl $235
80105b4e:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80105b53:	e9 55 f2 ff ff       	jmp    80104dad <alltraps>

80105b58 <vector236>:
.globl vector236
vector236:
  pushl $0
80105b58:	6a 00                	push   $0x0
  pushl $236
80105b5a:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80105b5f:	e9 49 f2 ff ff       	jmp    80104dad <alltraps>

80105b64 <vector237>:
.globl vector237
vector237:
  pushl $0
80105b64:	6a 00                	push   $0x0
  pushl $237
80105b66:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80105b6b:	e9 3d f2 ff ff       	jmp    80104dad <alltraps>

80105b70 <vector238>:
.globl vector238
vector238:
  pushl $0
80105b70:	6a 00                	push   $0x0
  pushl $238
80105b72:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80105b77:	e9 31 f2 ff ff       	jmp    80104dad <alltraps>

80105b7c <vector239>:
.globl vector239
vector239:
  pushl $0
80105b7c:	6a 00                	push   $0x0
  pushl $239
80105b7e:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80105b83:	e9 25 f2 ff ff       	jmp    80104dad <alltraps>

80105b88 <vector240>:
.globl vector240
vector240:
  pushl $0
80105b88:	6a 00                	push   $0x0
  pushl $240
80105b8a:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80105b8f:	e9 19 f2 ff ff       	jmp    80104dad <alltraps>

80105b94 <vector241>:
.globl vector241
vector241:
  pushl $0
80105b94:	6a 00                	push   $0x0
  pushl $241
80105b96:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80105b9b:	e9 0d f2 ff ff       	jmp    80104dad <alltraps>

80105ba0 <vector242>:
.globl vector242
vector242:
  pushl $0
80105ba0:	6a 00                	push   $0x0
  pushl $242
80105ba2:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80105ba7:	e9 01 f2 ff ff       	jmp    80104dad <alltraps>

80105bac <vector243>:
.globl vector243
vector243:
  pushl $0
80105bac:	6a 00                	push   $0x0
  pushl $243
80105bae:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80105bb3:	e9 f5 f1 ff ff       	jmp    80104dad <alltraps>

80105bb8 <vector244>:
.globl vector244
vector244:
  pushl $0
80105bb8:	6a 00                	push   $0x0
  pushl $244
80105bba:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80105bbf:	e9 e9 f1 ff ff       	jmp    80104dad <alltraps>

80105bc4 <vector245>:
.globl vector245
vector245:
  pushl $0
80105bc4:	6a 00                	push   $0x0
  pushl $245
80105bc6:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80105bcb:	e9 dd f1 ff ff       	jmp    80104dad <alltraps>

80105bd0 <vector246>:
.globl vector246
vector246:
  pushl $0
80105bd0:	6a 00                	push   $0x0
  pushl $246
80105bd2:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80105bd7:	e9 d1 f1 ff ff       	jmp    80104dad <alltraps>

80105bdc <vector247>:
.globl vector247
vector247:
  pushl $0
80105bdc:	6a 00                	push   $0x0
  pushl $247
80105bde:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80105be3:	e9 c5 f1 ff ff       	jmp    80104dad <alltraps>

80105be8 <vector248>:
.globl vector248
vector248:
  pushl $0
80105be8:	6a 00                	push   $0x0
  pushl $248
80105bea:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80105bef:	e9 b9 f1 ff ff       	jmp    80104dad <alltraps>

80105bf4 <vector249>:
.globl vector249
vector249:
  pushl $0
80105bf4:	6a 00                	push   $0x0
  pushl $249
80105bf6:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80105bfb:	e9 ad f1 ff ff       	jmp    80104dad <alltraps>

80105c00 <vector250>:
.globl vector250
vector250:
  pushl $0
80105c00:	6a 00                	push   $0x0
  pushl $250
80105c02:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80105c07:	e9 a1 f1 ff ff       	jmp    80104dad <alltraps>

80105c0c <vector251>:
.globl vector251
vector251:
  pushl $0
80105c0c:	6a 00                	push   $0x0
  pushl $251
80105c0e:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80105c13:	e9 95 f1 ff ff       	jmp    80104dad <alltraps>

80105c18 <vector252>:
.globl vector252
vector252:
  pushl $0
80105c18:	6a 00                	push   $0x0
  pushl $252
80105c1a:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80105c1f:	e9 89 f1 ff ff       	jmp    80104dad <alltraps>

80105c24 <vector253>:
.globl vector253
vector253:
  pushl $0
80105c24:	6a 00                	push   $0x0
  pushl $253
80105c26:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80105c2b:	e9 7d f1 ff ff       	jmp    80104dad <alltraps>

80105c30 <vector254>:
.globl vector254
vector254:
  pushl $0
80105c30:	6a 00                	push   $0x0
  pushl $254
80105c32:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80105c37:	e9 71 f1 ff ff       	jmp    80104dad <alltraps>

80105c3c <vector255>:
.globl vector255
vector255:
  pushl $0
80105c3c:	6a 00                	push   $0x0
  pushl $255
80105c3e:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80105c43:	e9 65 f1 ff ff       	jmp    80104dad <alltraps>

80105c48 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80105c48:	55                   	push   %ebp
80105c49:	89 e5                	mov    %esp,%ebp
80105c4b:	57                   	push   %edi
80105c4c:	56                   	push   %esi
80105c4d:	53                   	push   %ebx
80105c4e:	83 ec 0c             	sub    $0xc,%esp
80105c51:	89 d6                	mov    %edx,%esi
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80105c53:	c1 ea 16             	shr    $0x16,%edx
80105c56:	8d 3c 90             	lea    (%eax,%edx,4),%edi
  if(*pde & PTE_P){
80105c59:	8b 1f                	mov    (%edi),%ebx
80105c5b:	f6 c3 01             	test   $0x1,%bl
80105c5e:	74 22                	je     80105c82 <walkpgdir+0x3a>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80105c60:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
80105c66:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80105c6c:	c1 ee 0c             	shr    $0xc,%esi
80105c6f:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
80105c75:	8d 1c b3             	lea    (%ebx,%esi,4),%ebx
}
80105c78:	89 d8                	mov    %ebx,%eax
80105c7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105c7d:	5b                   	pop    %ebx
80105c7e:	5e                   	pop    %esi
80105c7f:	5f                   	pop    %edi
80105c80:	5d                   	pop    %ebp
80105c81:	c3                   	ret    
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80105c82:	85 c9                	test   %ecx,%ecx
80105c84:	74 2b                	je     80105cb1 <walkpgdir+0x69>
80105c86:	e8 64 c4 ff ff       	call   801020ef <kalloc>
80105c8b:	89 c3                	mov    %eax,%ebx
80105c8d:	85 c0                	test   %eax,%eax
80105c8f:	74 e7                	je     80105c78 <walkpgdir+0x30>
    memset(pgtab, 0, PGSIZE);
80105c91:	83 ec 04             	sub    $0x4,%esp
80105c94:	68 00 10 00 00       	push   $0x1000
80105c99:	6a 00                	push   $0x0
80105c9b:	50                   	push   %eax
80105c9c:	e8 85 e0 ff ff       	call   80103d26 <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80105ca1:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80105ca7:	83 c8 07             	or     $0x7,%eax
80105caa:	89 07                	mov    %eax,(%edi)
80105cac:	83 c4 10             	add    $0x10,%esp
80105caf:	eb bb                	jmp    80105c6c <walkpgdir+0x24>
      return 0;
80105cb1:	bb 00 00 00 00       	mov    $0x0,%ebx
80105cb6:	eb c0                	jmp    80105c78 <walkpgdir+0x30>

80105cb8 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80105cb8:	55                   	push   %ebp
80105cb9:	89 e5                	mov    %esp,%ebp
80105cbb:	57                   	push   %edi
80105cbc:	56                   	push   %esi
80105cbd:	53                   	push   %ebx
80105cbe:	83 ec 1c             	sub    $0x1c,%esp
80105cc1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105cc4:	8b 75 08             	mov    0x8(%ebp),%esi
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80105cc7:	89 d3                	mov    %edx,%ebx
80105cc9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80105ccf:	8d 7c 0a ff          	lea    -0x1(%edx,%ecx,1),%edi
80105cd3:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105cd9:	b9 01 00 00 00       	mov    $0x1,%ecx
80105cde:	89 da                	mov    %ebx,%edx
80105ce0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ce3:	e8 60 ff ff ff       	call   80105c48 <walkpgdir>
80105ce8:	85 c0                	test   %eax,%eax
80105cea:	74 2e                	je     80105d1a <mappages+0x62>
      return -1;
    if(*pte & PTE_P)
80105cec:	f6 00 01             	testb  $0x1,(%eax)
80105cef:	75 1c                	jne    80105d0d <mappages+0x55>
      panic("remap");
    *pte = pa | perm | PTE_P;
80105cf1:	89 f2                	mov    %esi,%edx
80105cf3:	0b 55 0c             	or     0xc(%ebp),%edx
80105cf6:	83 ca 01             	or     $0x1,%edx
80105cf9:	89 10                	mov    %edx,(%eax)
    if(a == last)
80105cfb:	39 fb                	cmp    %edi,%ebx
80105cfd:	74 28                	je     80105d27 <mappages+0x6f>
      break;
    a += PGSIZE;
80105cff:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
80105d05:	81 c6 00 10 00 00    	add    $0x1000,%esi
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105d0b:	eb cc                	jmp    80105cd9 <mappages+0x21>
      panic("remap");
80105d0d:	83 ec 0c             	sub    $0xc,%esp
80105d10:	68 ec 6d 10 80       	push   $0x80106dec
80105d15:	e8 2e a6 ff ff       	call   80100348 <panic>
      return -1;
80105d1a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80105d1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105d22:	5b                   	pop    %ebx
80105d23:	5e                   	pop    %esi
80105d24:	5f                   	pop    %edi
80105d25:	5d                   	pop    %ebp
80105d26:	c3                   	ret    
  return 0;
80105d27:	b8 00 00 00 00       	mov    $0x0,%eax
80105d2c:	eb f1                	jmp    80105d1f <mappages+0x67>

80105d2e <seginit>:
{
80105d2e:	55                   	push   %ebp
80105d2f:	89 e5                	mov    %esp,%ebp
80105d31:	53                   	push   %ebx
80105d32:	83 ec 14             	sub    $0x14,%esp
  c = &cpus[cpuid()];
80105d35:	e8 ec d4 ff ff       	call   80103226 <cpuid>
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80105d3a:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80105d40:	66 c7 80 58 38 11 80 	movw   $0xffff,-0x7feec7a8(%eax)
80105d47:	ff ff 
80105d49:	66 c7 80 5a 38 11 80 	movw   $0x0,-0x7feec7a6(%eax)
80105d50:	00 00 
80105d52:	c6 80 5c 38 11 80 00 	movb   $0x0,-0x7feec7a4(%eax)
80105d59:	0f b6 88 5d 38 11 80 	movzbl -0x7feec7a3(%eax),%ecx
80105d60:	83 e1 f0             	and    $0xfffffff0,%ecx
80105d63:	83 c9 1a             	or     $0x1a,%ecx
80105d66:	83 e1 9f             	and    $0xffffff9f,%ecx
80105d69:	83 c9 80             	or     $0xffffff80,%ecx
80105d6c:	88 88 5d 38 11 80    	mov    %cl,-0x7feec7a3(%eax)
80105d72:	0f b6 88 5e 38 11 80 	movzbl -0x7feec7a2(%eax),%ecx
80105d79:	83 c9 0f             	or     $0xf,%ecx
80105d7c:	83 e1 cf             	and    $0xffffffcf,%ecx
80105d7f:	83 c9 c0             	or     $0xffffffc0,%ecx
80105d82:	88 88 5e 38 11 80    	mov    %cl,-0x7feec7a2(%eax)
80105d88:	c6 80 5f 38 11 80 00 	movb   $0x0,-0x7feec7a1(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80105d8f:	66 c7 80 60 38 11 80 	movw   $0xffff,-0x7feec7a0(%eax)
80105d96:	ff ff 
80105d98:	66 c7 80 62 38 11 80 	movw   $0x0,-0x7feec79e(%eax)
80105d9f:	00 00 
80105da1:	c6 80 64 38 11 80 00 	movb   $0x0,-0x7feec79c(%eax)
80105da8:	0f b6 88 65 38 11 80 	movzbl -0x7feec79b(%eax),%ecx
80105daf:	83 e1 f0             	and    $0xfffffff0,%ecx
80105db2:	83 c9 12             	or     $0x12,%ecx
80105db5:	83 e1 9f             	and    $0xffffff9f,%ecx
80105db8:	83 c9 80             	or     $0xffffff80,%ecx
80105dbb:	88 88 65 38 11 80    	mov    %cl,-0x7feec79b(%eax)
80105dc1:	0f b6 88 66 38 11 80 	movzbl -0x7feec79a(%eax),%ecx
80105dc8:	83 c9 0f             	or     $0xf,%ecx
80105dcb:	83 e1 cf             	and    $0xffffffcf,%ecx
80105dce:	83 c9 c0             	or     $0xffffffc0,%ecx
80105dd1:	88 88 66 38 11 80    	mov    %cl,-0x7feec79a(%eax)
80105dd7:	c6 80 67 38 11 80 00 	movb   $0x0,-0x7feec799(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80105dde:	66 c7 80 68 38 11 80 	movw   $0xffff,-0x7feec798(%eax)
80105de5:	ff ff 
80105de7:	66 c7 80 6a 38 11 80 	movw   $0x0,-0x7feec796(%eax)
80105dee:	00 00 
80105df0:	c6 80 6c 38 11 80 00 	movb   $0x0,-0x7feec794(%eax)
80105df7:	c6 80 6d 38 11 80 fa 	movb   $0xfa,-0x7feec793(%eax)
80105dfe:	0f b6 88 6e 38 11 80 	movzbl -0x7feec792(%eax),%ecx
80105e05:	83 c9 0f             	or     $0xf,%ecx
80105e08:	83 e1 cf             	and    $0xffffffcf,%ecx
80105e0b:	83 c9 c0             	or     $0xffffffc0,%ecx
80105e0e:	88 88 6e 38 11 80    	mov    %cl,-0x7feec792(%eax)
80105e14:	c6 80 6f 38 11 80 00 	movb   $0x0,-0x7feec791(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80105e1b:	66 c7 80 70 38 11 80 	movw   $0xffff,-0x7feec790(%eax)
80105e22:	ff ff 
80105e24:	66 c7 80 72 38 11 80 	movw   $0x0,-0x7feec78e(%eax)
80105e2b:	00 00 
80105e2d:	c6 80 74 38 11 80 00 	movb   $0x0,-0x7feec78c(%eax)
80105e34:	c6 80 75 38 11 80 f2 	movb   $0xf2,-0x7feec78b(%eax)
80105e3b:	0f b6 88 76 38 11 80 	movzbl -0x7feec78a(%eax),%ecx
80105e42:	83 c9 0f             	or     $0xf,%ecx
80105e45:	83 e1 cf             	and    $0xffffffcf,%ecx
80105e48:	83 c9 c0             	or     $0xffffffc0,%ecx
80105e4b:	88 88 76 38 11 80    	mov    %cl,-0x7feec78a(%eax)
80105e51:	c6 80 77 38 11 80 00 	movb   $0x0,-0x7feec789(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80105e58:	05 50 38 11 80       	add    $0x80113850,%eax
  pd[0] = size-1;
80105e5d:	66 c7 45 f2 2f 00    	movw   $0x2f,-0xe(%ebp)
  pd[1] = (uint)p;
80105e63:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
80105e67:	c1 e8 10             	shr    $0x10,%eax
80105e6a:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80105e6e:	8d 45 f2             	lea    -0xe(%ebp),%eax
80105e71:	0f 01 10             	lgdtl  (%eax)
}
80105e74:	83 c4 14             	add    $0x14,%esp
80105e77:	5b                   	pop    %ebx
80105e78:	5d                   	pop    %ebp
80105e79:	c3                   	ret    

80105e7a <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80105e7a:	55                   	push   %ebp
80105e7b:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80105e7d:	a1 84 45 11 80       	mov    0x80114584,%eax
80105e82:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
80105e87:	0f 22 d8             	mov    %eax,%cr3
}
80105e8a:	5d                   	pop    %ebp
80105e8b:	c3                   	ret    

80105e8c <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80105e8c:	55                   	push   %ebp
80105e8d:	89 e5                	mov    %esp,%ebp
80105e8f:	57                   	push   %edi
80105e90:	56                   	push   %esi
80105e91:	53                   	push   %ebx
80105e92:	83 ec 1c             	sub    $0x1c,%esp
80105e95:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
80105e98:	85 f6                	test   %esi,%esi
80105e9a:	0f 84 dd 00 00 00    	je     80105f7d <switchuvm+0xf1>
    panic("switchuvm: no process");
  if(p->kstack == 0)
80105ea0:	83 7e 0c 00          	cmpl   $0x0,0xc(%esi)
80105ea4:	0f 84 e0 00 00 00    	je     80105f8a <switchuvm+0xfe>
    panic("switchuvm: no kstack");
  if(p->pgdir == 0)
80105eaa:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
80105eae:	0f 84 e3 00 00 00    	je     80105f97 <switchuvm+0x10b>
    panic("switchuvm: no pgdir");

  pushcli();
80105eb4:	e8 e4 dc ff ff       	call   80103b9d <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80105eb9:	e8 0c d3 ff ff       	call   801031ca <mycpu>
80105ebe:	89 c3                	mov    %eax,%ebx
80105ec0:	e8 05 d3 ff ff       	call   801031ca <mycpu>
80105ec5:	8d 78 08             	lea    0x8(%eax),%edi
80105ec8:	e8 fd d2 ff ff       	call   801031ca <mycpu>
80105ecd:	83 c0 08             	add    $0x8,%eax
80105ed0:	c1 e8 10             	shr    $0x10,%eax
80105ed3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105ed6:	e8 ef d2 ff ff       	call   801031ca <mycpu>
80105edb:	83 c0 08             	add    $0x8,%eax
80105ede:	c1 e8 18             	shr    $0x18,%eax
80105ee1:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80105ee8:	67 00 
80105eea:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
80105ef1:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
80105ef5:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80105efb:	0f b6 93 9d 00 00 00 	movzbl 0x9d(%ebx),%edx
80105f02:	83 e2 f0             	and    $0xfffffff0,%edx
80105f05:	83 ca 19             	or     $0x19,%edx
80105f08:	83 e2 9f             	and    $0xffffff9f,%edx
80105f0b:	83 ca 80             	or     $0xffffff80,%edx
80105f0e:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80105f14:	c6 83 9e 00 00 00 40 	movb   $0x40,0x9e(%ebx)
80105f1b:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80105f21:	e8 a4 d2 ff ff       	call   801031ca <mycpu>
80105f26:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80105f2d:	83 e2 ef             	and    $0xffffffef,%edx
80105f30:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80105f36:	e8 8f d2 ff ff       	call   801031ca <mycpu>
80105f3b:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80105f41:	8b 5e 0c             	mov    0xc(%esi),%ebx
80105f44:	e8 81 d2 ff ff       	call   801031ca <mycpu>
80105f49:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80105f4f:	89 58 0c             	mov    %ebx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80105f52:	e8 73 d2 ff ff       	call   801031ca <mycpu>
80105f57:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
80105f5d:	b8 28 00 00 00       	mov    $0x28,%eax
80105f62:	0f 00 d8             	ltr    %ax
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
80105f65:	8b 46 08             	mov    0x8(%esi),%eax
80105f68:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
80105f6d:	0f 22 d8             	mov    %eax,%cr3
  popcli();
80105f70:	e8 65 dc ff ff       	call   80103bda <popcli>
}
80105f75:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105f78:	5b                   	pop    %ebx
80105f79:	5e                   	pop    %esi
80105f7a:	5f                   	pop    %edi
80105f7b:	5d                   	pop    %ebp
80105f7c:	c3                   	ret    
    panic("switchuvm: no process");
80105f7d:	83 ec 0c             	sub    $0xc,%esp
80105f80:	68 f2 6d 10 80       	push   $0x80106df2
80105f85:	e8 be a3 ff ff       	call   80100348 <panic>
    panic("switchuvm: no kstack");
80105f8a:	83 ec 0c             	sub    $0xc,%esp
80105f8d:	68 08 6e 10 80       	push   $0x80106e08
80105f92:	e8 b1 a3 ff ff       	call   80100348 <panic>
    panic("switchuvm: no pgdir");
80105f97:	83 ec 0c             	sub    $0xc,%esp
80105f9a:	68 1d 6e 10 80       	push   $0x80106e1d
80105f9f:	e8 a4 a3 ff ff       	call   80100348 <panic>

80105fa4 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80105fa4:	55                   	push   %ebp
80105fa5:	89 e5                	mov    %esp,%ebp
80105fa7:	56                   	push   %esi
80105fa8:	53                   	push   %ebx
80105fa9:	8b 75 10             	mov    0x10(%ebp),%esi
  char *mem;

  if(sz >= PGSIZE)
80105fac:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80105fb2:	77 4c                	ja     80106000 <inituvm+0x5c>
    panic("inituvm: more than a page");
  mem = kalloc();
80105fb4:	e8 36 c1 ff ff       	call   801020ef <kalloc>
80105fb9:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
80105fbb:	83 ec 04             	sub    $0x4,%esp
80105fbe:	68 00 10 00 00       	push   $0x1000
80105fc3:	6a 00                	push   $0x0
80105fc5:	50                   	push   %eax
80105fc6:	e8 5b dd ff ff       	call   80103d26 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80105fcb:	83 c4 08             	add    $0x8,%esp
80105fce:	6a 06                	push   $0x6
80105fd0:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80105fd6:	50                   	push   %eax
80105fd7:	b9 00 10 00 00       	mov    $0x1000,%ecx
80105fdc:	ba 00 00 00 00       	mov    $0x0,%edx
80105fe1:	8b 45 08             	mov    0x8(%ebp),%eax
80105fe4:	e8 cf fc ff ff       	call   80105cb8 <mappages>
  memmove(mem, init, sz);
80105fe9:	83 c4 0c             	add    $0xc,%esp
80105fec:	56                   	push   %esi
80105fed:	ff 75 0c             	pushl  0xc(%ebp)
80105ff0:	53                   	push   %ebx
80105ff1:	e8 ab dd ff ff       	call   80103da1 <memmove>
}
80105ff6:	83 c4 10             	add    $0x10,%esp
80105ff9:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105ffc:	5b                   	pop    %ebx
80105ffd:	5e                   	pop    %esi
80105ffe:	5d                   	pop    %ebp
80105fff:	c3                   	ret    
    panic("inituvm: more than a page");
80106000:	83 ec 0c             	sub    $0xc,%esp
80106003:	68 31 6e 10 80       	push   $0x80106e31
80106008:	e8 3b a3 ff ff       	call   80100348 <panic>

8010600d <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
8010600d:	55                   	push   %ebp
8010600e:	89 e5                	mov    %esp,%ebp
80106010:	57                   	push   %edi
80106011:	56                   	push   %esi
80106012:	53                   	push   %ebx
80106013:	83 ec 0c             	sub    $0xc,%esp
80106016:	8b 7d 18             	mov    0x18(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80106019:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
80106020:	75 07                	jne    80106029 <loaduvm+0x1c>
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80106022:	bb 00 00 00 00       	mov    $0x0,%ebx
80106027:	eb 3c                	jmp    80106065 <loaduvm+0x58>
    panic("loaduvm: addr must be page aligned");
80106029:	83 ec 0c             	sub    $0xc,%esp
8010602c:	68 ec 6e 10 80       	push   $0x80106eec
80106031:	e8 12 a3 ff ff       	call   80100348 <panic>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
80106036:	83 ec 0c             	sub    $0xc,%esp
80106039:	68 4b 6e 10 80       	push   $0x80106e4b
8010603e:	e8 05 a3 ff ff       	call   80100348 <panic>
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
80106043:	05 00 00 00 80       	add    $0x80000000,%eax
80106048:	56                   	push   %esi
80106049:	89 da                	mov    %ebx,%edx
8010604b:	03 55 14             	add    0x14(%ebp),%edx
8010604e:	52                   	push   %edx
8010604f:	50                   	push   %eax
80106050:	ff 75 10             	pushl  0x10(%ebp)
80106053:	e8 4f b7 ff ff       	call   801017a7 <readi>
80106058:	83 c4 10             	add    $0x10,%esp
8010605b:	39 f0                	cmp    %esi,%eax
8010605d:	75 47                	jne    801060a6 <loaduvm+0x99>
  for(i = 0; i < sz; i += PGSIZE){
8010605f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106065:	39 fb                	cmp    %edi,%ebx
80106067:	73 30                	jae    80106099 <loaduvm+0x8c>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80106069:	89 da                	mov    %ebx,%edx
8010606b:	03 55 0c             	add    0xc(%ebp),%edx
8010606e:	b9 00 00 00 00       	mov    $0x0,%ecx
80106073:	8b 45 08             	mov    0x8(%ebp),%eax
80106076:	e8 cd fb ff ff       	call   80105c48 <walkpgdir>
8010607b:	85 c0                	test   %eax,%eax
8010607d:	74 b7                	je     80106036 <loaduvm+0x29>
    pa = PTE_ADDR(*pte);
8010607f:	8b 00                	mov    (%eax),%eax
80106081:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
80106086:	89 fe                	mov    %edi,%esi
80106088:	29 de                	sub    %ebx,%esi
8010608a:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80106090:	76 b1                	jbe    80106043 <loaduvm+0x36>
      n = PGSIZE;
80106092:	be 00 10 00 00       	mov    $0x1000,%esi
80106097:	eb aa                	jmp    80106043 <loaduvm+0x36>
      return -1;
  }
  return 0;
80106099:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010609e:	8d 65 f4             	lea    -0xc(%ebp),%esp
801060a1:	5b                   	pop    %ebx
801060a2:	5e                   	pop    %esi
801060a3:	5f                   	pop    %edi
801060a4:	5d                   	pop    %ebp
801060a5:	c3                   	ret    
      return -1;
801060a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060ab:	eb f1                	jmp    8010609e <loaduvm+0x91>

801060ad <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801060ad:	55                   	push   %ebp
801060ae:	89 e5                	mov    %esp,%ebp
801060b0:	57                   	push   %edi
801060b1:	56                   	push   %esi
801060b2:	53                   	push   %ebx
801060b3:	83 ec 0c             	sub    $0xc,%esp
801060b6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801060b9:	39 7d 10             	cmp    %edi,0x10(%ebp)
801060bc:	73 11                	jae    801060cf <deallocuvm+0x22>
    return oldsz;

  a = PGROUNDUP(newsz);
801060be:	8b 45 10             	mov    0x10(%ebp),%eax
801060c1:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801060c7:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
801060cd:	eb 19                	jmp    801060e8 <deallocuvm+0x3b>
    return oldsz;
801060cf:	89 f8                	mov    %edi,%eax
801060d1:	eb 64                	jmp    80106137 <deallocuvm+0x8a>
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801060d3:	c1 eb 16             	shr    $0x16,%ebx
801060d6:	83 c3 01             	add    $0x1,%ebx
801060d9:	c1 e3 16             	shl    $0x16,%ebx
801060dc:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
  for(; a  < oldsz; a += PGSIZE){
801060e2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801060e8:	39 fb                	cmp    %edi,%ebx
801060ea:	73 48                	jae    80106134 <deallocuvm+0x87>
    pte = walkpgdir(pgdir, (char*)a, 0);
801060ec:	b9 00 00 00 00       	mov    $0x0,%ecx
801060f1:	89 da                	mov    %ebx,%edx
801060f3:	8b 45 08             	mov    0x8(%ebp),%eax
801060f6:	e8 4d fb ff ff       	call   80105c48 <walkpgdir>
801060fb:	89 c6                	mov    %eax,%esi
    if(!pte)
801060fd:	85 c0                	test   %eax,%eax
801060ff:	74 d2                	je     801060d3 <deallocuvm+0x26>
    else if((*pte & PTE_P) != 0){
80106101:	8b 00                	mov    (%eax),%eax
80106103:	a8 01                	test   $0x1,%al
80106105:	74 db                	je     801060e2 <deallocuvm+0x35>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
80106107:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010610c:	74 19                	je     80106127 <deallocuvm+0x7a>
        panic("kfree");
      char *v = P2V(pa);
8010610e:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
80106113:	83 ec 0c             	sub    $0xc,%esp
80106116:	50                   	push   %eax
80106117:	e8 bc be ff ff       	call   80101fd8 <kfree>
      *pte = 0;
8010611c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80106122:	83 c4 10             	add    $0x10,%esp
80106125:	eb bb                	jmp    801060e2 <deallocuvm+0x35>
        panic("kfree");
80106127:	83 ec 0c             	sub    $0xc,%esp
8010612a:	68 4e 67 10 80       	push   $0x8010674e
8010612f:	e8 14 a2 ff ff       	call   80100348 <panic>
    }
  }
  return newsz;
80106134:	8b 45 10             	mov    0x10(%ebp),%eax
}
80106137:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010613a:	5b                   	pop    %ebx
8010613b:	5e                   	pop    %esi
8010613c:	5f                   	pop    %edi
8010613d:	5d                   	pop    %ebp
8010613e:	c3                   	ret    

8010613f <allocuvm>:
{
8010613f:	55                   	push   %ebp
80106140:	89 e5                	mov    %esp,%ebp
80106142:	57                   	push   %edi
80106143:	56                   	push   %esi
80106144:	53                   	push   %ebx
80106145:	83 ec 1c             	sub    $0x1c,%esp
80106148:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(newsz >= KERNBASE)
8010614b:	89 7d e4             	mov    %edi,-0x1c(%ebp)
8010614e:	85 ff                	test   %edi,%edi
80106150:	0f 88 c1 00 00 00    	js     80106217 <allocuvm+0xd8>
  if(newsz < oldsz)
80106156:	3b 7d 0c             	cmp    0xc(%ebp),%edi
80106159:	72 5c                	jb     801061b7 <allocuvm+0x78>
  a = PGROUNDUP(oldsz);
8010615b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010615e:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80106164:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a < newsz; a += PGSIZE){
8010616a:	39 fb                	cmp    %edi,%ebx
8010616c:	0f 83 ac 00 00 00    	jae    8010621e <allocuvm+0xdf>
    mem = kalloc();
80106172:	e8 78 bf ff ff       	call   801020ef <kalloc>
80106177:	89 c6                	mov    %eax,%esi
    if(mem == 0){
80106179:	85 c0                	test   %eax,%eax
8010617b:	74 42                	je     801061bf <allocuvm+0x80>
    memset(mem, 0, PGSIZE);
8010617d:	83 ec 04             	sub    $0x4,%esp
80106180:	68 00 10 00 00       	push   $0x1000
80106185:	6a 00                	push   $0x0
80106187:	50                   	push   %eax
80106188:	e8 99 db ff ff       	call   80103d26 <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
8010618d:	83 c4 08             	add    $0x8,%esp
80106190:	6a 06                	push   $0x6
80106192:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
80106198:	50                   	push   %eax
80106199:	b9 00 10 00 00       	mov    $0x1000,%ecx
8010619e:	89 da                	mov    %ebx,%edx
801061a0:	8b 45 08             	mov    0x8(%ebp),%eax
801061a3:	e8 10 fb ff ff       	call   80105cb8 <mappages>
801061a8:	83 c4 10             	add    $0x10,%esp
801061ab:	85 c0                	test   %eax,%eax
801061ad:	78 38                	js     801061e7 <allocuvm+0xa8>
  for(; a < newsz; a += PGSIZE){
801061af:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801061b5:	eb b3                	jmp    8010616a <allocuvm+0x2b>
    return oldsz;
801061b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801061ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801061bd:	eb 5f                	jmp    8010621e <allocuvm+0xdf>
      cprintf("allocuvm out of memory\n");
801061bf:	83 ec 0c             	sub    $0xc,%esp
801061c2:	68 69 6e 10 80       	push   $0x80106e69
801061c7:	e8 3f a4 ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801061cc:	83 c4 0c             	add    $0xc,%esp
801061cf:	ff 75 0c             	pushl  0xc(%ebp)
801061d2:	57                   	push   %edi
801061d3:	ff 75 08             	pushl  0x8(%ebp)
801061d6:	e8 d2 fe ff ff       	call   801060ad <deallocuvm>
      return 0;
801061db:	83 c4 10             	add    $0x10,%esp
801061de:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801061e5:	eb 37                	jmp    8010621e <allocuvm+0xdf>
      cprintf("allocuvm out of memory (2)\n");
801061e7:	83 ec 0c             	sub    $0xc,%esp
801061ea:	68 81 6e 10 80       	push   $0x80106e81
801061ef:	e8 17 a4 ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801061f4:	83 c4 0c             	add    $0xc,%esp
801061f7:	ff 75 0c             	pushl  0xc(%ebp)
801061fa:	57                   	push   %edi
801061fb:	ff 75 08             	pushl  0x8(%ebp)
801061fe:	e8 aa fe ff ff       	call   801060ad <deallocuvm>
      kfree(mem);
80106203:	89 34 24             	mov    %esi,(%esp)
80106206:	e8 cd bd ff ff       	call   80101fd8 <kfree>
      return 0;
8010620b:	83 c4 10             	add    $0x10,%esp
8010620e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106215:	eb 07                	jmp    8010621e <allocuvm+0xdf>
    return 0;
80106217:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
8010621e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106221:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106224:	5b                   	pop    %ebx
80106225:	5e                   	pop    %esi
80106226:	5f                   	pop    %edi
80106227:	5d                   	pop    %ebp
80106228:	c3                   	ret    

80106229 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80106229:	55                   	push   %ebp
8010622a:	89 e5                	mov    %esp,%ebp
8010622c:	56                   	push   %esi
8010622d:	53                   	push   %ebx
8010622e:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
80106231:	85 f6                	test   %esi,%esi
80106233:	74 1a                	je     8010624f <freevm+0x26>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
80106235:	83 ec 04             	sub    $0x4,%esp
80106238:	6a 00                	push   $0x0
8010623a:	68 00 00 00 80       	push   $0x80000000
8010623f:	56                   	push   %esi
80106240:	e8 68 fe ff ff       	call   801060ad <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80106245:	83 c4 10             	add    $0x10,%esp
80106248:	bb 00 00 00 00       	mov    $0x0,%ebx
8010624d:	eb 10                	jmp    8010625f <freevm+0x36>
    panic("freevm: no pgdir");
8010624f:	83 ec 0c             	sub    $0xc,%esp
80106252:	68 9d 6e 10 80       	push   $0x80106e9d
80106257:	e8 ec a0 ff ff       	call   80100348 <panic>
  for(i = 0; i < NPDENTRIES; i++){
8010625c:	83 c3 01             	add    $0x1,%ebx
8010625f:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
80106265:	77 1f                	ja     80106286 <freevm+0x5d>
    if(pgdir[i] & PTE_P){
80106267:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
8010626a:	a8 01                	test   $0x1,%al
8010626c:	74 ee                	je     8010625c <freevm+0x33>
      char * v = P2V(PTE_ADDR(pgdir[i]));
8010626e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106273:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
80106278:	83 ec 0c             	sub    $0xc,%esp
8010627b:	50                   	push   %eax
8010627c:	e8 57 bd ff ff       	call   80101fd8 <kfree>
80106281:	83 c4 10             	add    $0x10,%esp
80106284:	eb d6                	jmp    8010625c <freevm+0x33>
    }
  }
  kfree((char*)pgdir);
80106286:	83 ec 0c             	sub    $0xc,%esp
80106289:	56                   	push   %esi
8010628a:	e8 49 bd ff ff       	call   80101fd8 <kfree>
}
8010628f:	83 c4 10             	add    $0x10,%esp
80106292:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106295:	5b                   	pop    %ebx
80106296:	5e                   	pop    %esi
80106297:	5d                   	pop    %ebp
80106298:	c3                   	ret    

80106299 <setupkvm>:
{
80106299:	55                   	push   %ebp
8010629a:	89 e5                	mov    %esp,%ebp
8010629c:	56                   	push   %esi
8010629d:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
8010629e:	e8 4c be ff ff       	call   801020ef <kalloc>
801062a3:	89 c6                	mov    %eax,%esi
801062a5:	85 c0                	test   %eax,%eax
801062a7:	74 55                	je     801062fe <setupkvm+0x65>
  memset(pgdir, 0, PGSIZE);
801062a9:	83 ec 04             	sub    $0x4,%esp
801062ac:	68 00 10 00 00       	push   $0x1000
801062b1:	6a 00                	push   $0x0
801062b3:	50                   	push   %eax
801062b4:	e8 6d da ff ff       	call   80103d26 <memset>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801062b9:	83 c4 10             	add    $0x10,%esp
801062bc:	bb 20 94 10 80       	mov    $0x80109420,%ebx
801062c1:	81 fb 60 94 10 80    	cmp    $0x80109460,%ebx
801062c7:	73 35                	jae    801062fe <setupkvm+0x65>
                (uint)k->phys_start, k->perm) < 0) {
801062c9:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801062cc:	8b 4b 08             	mov    0x8(%ebx),%ecx
801062cf:	29 c1                	sub    %eax,%ecx
801062d1:	83 ec 08             	sub    $0x8,%esp
801062d4:	ff 73 0c             	pushl  0xc(%ebx)
801062d7:	50                   	push   %eax
801062d8:	8b 13                	mov    (%ebx),%edx
801062da:	89 f0                	mov    %esi,%eax
801062dc:	e8 d7 f9 ff ff       	call   80105cb8 <mappages>
801062e1:	83 c4 10             	add    $0x10,%esp
801062e4:	85 c0                	test   %eax,%eax
801062e6:	78 05                	js     801062ed <setupkvm+0x54>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801062e8:	83 c3 10             	add    $0x10,%ebx
801062eb:	eb d4                	jmp    801062c1 <setupkvm+0x28>
      freevm(pgdir);
801062ed:	83 ec 0c             	sub    $0xc,%esp
801062f0:	56                   	push   %esi
801062f1:	e8 33 ff ff ff       	call   80106229 <freevm>
      return 0;
801062f6:	83 c4 10             	add    $0x10,%esp
801062f9:	be 00 00 00 00       	mov    $0x0,%esi
}
801062fe:	89 f0                	mov    %esi,%eax
80106300:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106303:	5b                   	pop    %ebx
80106304:	5e                   	pop    %esi
80106305:	5d                   	pop    %ebp
80106306:	c3                   	ret    

80106307 <kvmalloc>:
{
80106307:	55                   	push   %ebp
80106308:	89 e5                	mov    %esp,%ebp
8010630a:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
8010630d:	e8 87 ff ff ff       	call   80106299 <setupkvm>
80106312:	a3 84 45 11 80       	mov    %eax,0x80114584
  switchkvm();
80106317:	e8 5e fb ff ff       	call   80105e7a <switchkvm>
}
8010631c:	c9                   	leave  
8010631d:	c3                   	ret    

8010631e <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010631e:	55                   	push   %ebp
8010631f:	89 e5                	mov    %esp,%ebp
80106321:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106324:	b9 00 00 00 00       	mov    $0x0,%ecx
80106329:	8b 55 0c             	mov    0xc(%ebp),%edx
8010632c:	8b 45 08             	mov    0x8(%ebp),%eax
8010632f:	e8 14 f9 ff ff       	call   80105c48 <walkpgdir>
  if(pte == 0)
80106334:	85 c0                	test   %eax,%eax
80106336:	74 05                	je     8010633d <clearpteu+0x1f>
    panic("clearpteu");
  *pte &= ~PTE_U;
80106338:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
8010633b:	c9                   	leave  
8010633c:	c3                   	ret    
    panic("clearpteu");
8010633d:	83 ec 0c             	sub    $0xc,%esp
80106340:	68 ae 6e 10 80       	push   $0x80106eae
80106345:	e8 fe 9f ff ff       	call   80100348 <panic>

8010634a <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
8010634a:	55                   	push   %ebp
8010634b:	89 e5                	mov    %esp,%ebp
8010634d:	57                   	push   %edi
8010634e:	56                   	push   %esi
8010634f:	53                   	push   %ebx
80106350:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80106353:	e8 41 ff ff ff       	call   80106299 <setupkvm>
80106358:	89 45 dc             	mov    %eax,-0x24(%ebp)
8010635b:	85 c0                	test   %eax,%eax
8010635d:	0f 84 b8 00 00 00    	je     8010641b <copyuvm+0xd1>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80106363:	bf 00 00 00 00       	mov    $0x0,%edi
80106368:	3b 7d 0c             	cmp    0xc(%ebp),%edi
8010636b:	0f 83 aa 00 00 00    	jae    8010641b <copyuvm+0xd1>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80106371:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80106374:	b9 00 00 00 00       	mov    $0x0,%ecx
80106379:	89 fa                	mov    %edi,%edx
8010637b:	8b 45 08             	mov    0x8(%ebp),%eax
8010637e:	e8 c5 f8 ff ff       	call   80105c48 <walkpgdir>
80106383:	85 c0                	test   %eax,%eax
80106385:	74 65                	je     801063ec <copyuvm+0xa2>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
80106387:	8b 00                	mov    (%eax),%eax
80106389:	a8 01                	test   $0x1,%al
8010638b:	74 6c                	je     801063f9 <copyuvm+0xaf>
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
8010638d:	89 c6                	mov    %eax,%esi
8010638f:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    flags = PTE_FLAGS(*pte);
80106395:	25 ff 0f 00 00       	and    $0xfff,%eax
8010639a:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if((mem = kalloc()) == 0)
8010639d:	e8 4d bd ff ff       	call   801020ef <kalloc>
801063a2:	89 c3                	mov    %eax,%ebx
801063a4:	85 c0                	test   %eax,%eax
801063a6:	74 5e                	je     80106406 <copyuvm+0xbc>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
801063a8:	81 c6 00 00 00 80    	add    $0x80000000,%esi
801063ae:	83 ec 04             	sub    $0x4,%esp
801063b1:	68 00 10 00 00       	push   $0x1000
801063b6:	56                   	push   %esi
801063b7:	50                   	push   %eax
801063b8:	e8 e4 d9 ff ff       	call   80103da1 <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
801063bd:	83 c4 08             	add    $0x8,%esp
801063c0:	ff 75 e0             	pushl  -0x20(%ebp)
801063c3:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
801063c9:	53                   	push   %ebx
801063ca:	b9 00 10 00 00       	mov    $0x1000,%ecx
801063cf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801063d2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801063d5:	e8 de f8 ff ff       	call   80105cb8 <mappages>
801063da:	83 c4 10             	add    $0x10,%esp
801063dd:	85 c0                	test   %eax,%eax
801063df:	78 25                	js     80106406 <copyuvm+0xbc>
  for(i = 0; i < sz; i += PGSIZE){
801063e1:	81 c7 00 10 00 00    	add    $0x1000,%edi
801063e7:	e9 7c ff ff ff       	jmp    80106368 <copyuvm+0x1e>
      panic("copyuvm: pte should exist");
801063ec:	83 ec 0c             	sub    $0xc,%esp
801063ef:	68 b8 6e 10 80       	push   $0x80106eb8
801063f4:	e8 4f 9f ff ff       	call   80100348 <panic>
      panic("copyuvm: page not present");
801063f9:	83 ec 0c             	sub    $0xc,%esp
801063fc:	68 d2 6e 10 80       	push   $0x80106ed2
80106401:	e8 42 9f ff ff       	call   80100348 <panic>
      goto bad;
  }
  return d;

bad:
  freevm(d);
80106406:	83 ec 0c             	sub    $0xc,%esp
80106409:	ff 75 dc             	pushl  -0x24(%ebp)
8010640c:	e8 18 fe ff ff       	call   80106229 <freevm>
  return 0;
80106411:	83 c4 10             	add    $0x10,%esp
80106414:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
}
8010641b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010641e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106421:	5b                   	pop    %ebx
80106422:	5e                   	pop    %esi
80106423:	5f                   	pop    %edi
80106424:	5d                   	pop    %ebp
80106425:	c3                   	ret    

80106426 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80106426:	55                   	push   %ebp
80106427:	89 e5                	mov    %esp,%ebp
80106429:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010642c:	b9 00 00 00 00       	mov    $0x0,%ecx
80106431:	8b 55 0c             	mov    0xc(%ebp),%edx
80106434:	8b 45 08             	mov    0x8(%ebp),%eax
80106437:	e8 0c f8 ff ff       	call   80105c48 <walkpgdir>
  if((*pte & PTE_P) == 0)
8010643c:	8b 00                	mov    (%eax),%eax
8010643e:	a8 01                	test   $0x1,%al
80106440:	74 10                	je     80106452 <uva2ka+0x2c>
    return 0;
  if((*pte & PTE_U) == 0)
80106442:	a8 04                	test   $0x4,%al
80106444:	74 13                	je     80106459 <uva2ka+0x33>
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
80106446:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010644b:	05 00 00 00 80       	add    $0x80000000,%eax
}
80106450:	c9                   	leave  
80106451:	c3                   	ret    
    return 0;
80106452:	b8 00 00 00 00       	mov    $0x0,%eax
80106457:	eb f7                	jmp    80106450 <uva2ka+0x2a>
    return 0;
80106459:	b8 00 00 00 00       	mov    $0x0,%eax
8010645e:	eb f0                	jmp    80106450 <uva2ka+0x2a>

80106460 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80106460:	55                   	push   %ebp
80106461:	89 e5                	mov    %esp,%ebp
80106463:	57                   	push   %edi
80106464:	56                   	push   %esi
80106465:	53                   	push   %ebx
80106466:	83 ec 0c             	sub    $0xc,%esp
80106469:	8b 7d 14             	mov    0x14(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
8010646c:	eb 25                	jmp    80106493 <copyout+0x33>
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
8010646e:	8b 55 0c             	mov    0xc(%ebp),%edx
80106471:	29 f2                	sub    %esi,%edx
80106473:	01 d0                	add    %edx,%eax
80106475:	83 ec 04             	sub    $0x4,%esp
80106478:	53                   	push   %ebx
80106479:	ff 75 10             	pushl  0x10(%ebp)
8010647c:	50                   	push   %eax
8010647d:	e8 1f d9 ff ff       	call   80103da1 <memmove>
    len -= n;
80106482:	29 df                	sub    %ebx,%edi
    buf += n;
80106484:	01 5d 10             	add    %ebx,0x10(%ebp)
    va = va0 + PGSIZE;
80106487:	8d 86 00 10 00 00    	lea    0x1000(%esi),%eax
8010648d:	89 45 0c             	mov    %eax,0xc(%ebp)
80106490:	83 c4 10             	add    $0x10,%esp
  while(len > 0){
80106493:	85 ff                	test   %edi,%edi
80106495:	74 2f                	je     801064c6 <copyout+0x66>
    va0 = (uint)PGROUNDDOWN(va);
80106497:	8b 75 0c             	mov    0xc(%ebp),%esi
8010649a:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
801064a0:	83 ec 08             	sub    $0x8,%esp
801064a3:	56                   	push   %esi
801064a4:	ff 75 08             	pushl  0x8(%ebp)
801064a7:	e8 7a ff ff ff       	call   80106426 <uva2ka>
    if(pa0 == 0)
801064ac:	83 c4 10             	add    $0x10,%esp
801064af:	85 c0                	test   %eax,%eax
801064b1:	74 20                	je     801064d3 <copyout+0x73>
    n = PGSIZE - (va - va0);
801064b3:	89 f3                	mov    %esi,%ebx
801064b5:	2b 5d 0c             	sub    0xc(%ebp),%ebx
801064b8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(n > len)
801064be:	39 df                	cmp    %ebx,%edi
801064c0:	73 ac                	jae    8010646e <copyout+0xe>
      n = len;
801064c2:	89 fb                	mov    %edi,%ebx
801064c4:	eb a8                	jmp    8010646e <copyout+0xe>
  }
  return 0;
801064c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
801064ce:	5b                   	pop    %ebx
801064cf:	5e                   	pop    %esi
801064d0:	5f                   	pop    %edi
801064d1:	5d                   	pop    %ebp
801064d2:	c3                   	ret    
      return -1;
801064d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064d8:	eb f1                	jmp    801064cb <copyout+0x6b>

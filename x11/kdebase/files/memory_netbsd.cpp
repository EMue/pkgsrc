/* $NetBSD: memory_netbsd.cpp,v 1.2 2000/05/20 20:39:41 abs Exp $ */

#include <sys/param.h>
#if __NetBSD_Version__ > 103080000
#define UVM
#endif

#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#ifdef UVM
#include <uvm/uvm_extern.h>
#else
#include <vm/vm_swap.h>
#endif

void KMemoryWidget::update()
{
  struct swapent *swaplist;
  int mib[2], memory, nswap, rnswap, totalswap, freeswap, usedswap;
  size_t len;
#ifdef UVM
  struct  uvmexp uvmexp;
#endif
  
  /* memory */
  mib[0] = CTL_HW;
  mib[1] = HW_PHYSMEM;
  len = sizeof(memory);
  if( sysctl(mib,2,&memory,&len,NULL,0)< 0 )
    totalMem->setText(klocale->translate("Problem in determining"));
  else
    totalMem->setText(format(memory));

#ifdef UVM
  mib[0] = CTL_VM;
  mib[1] = VM_UVMEXP;
  len = sizeof(uvmexp);
  if ( sysctl(mib, 2, &uvmexp, &len, NULL, 0) < 0 )
    {
    freeMem->setText(klocale->translate("Problem in determining"));
    activeMem->setText(klocale->translate("Problem in determining"));
    inactiveMem->setText(klocale->translate("Problem in determining"));
    swapMem->setText(klocale->translate("Problem in determining"));
    freeSwapMem->setText(klocale->translate("Problem in determining"));
    }
  else
    {
    freeMem->setText(format((long)uvmexp.free * uvmexp.pagesize));
    activeMem->setText(format((long)uvmexp.active * uvmexp.pagesize));
    inactiveMem->setText(format((long)uvmexp.inactive * uvmexp.pagesize));
    swapMem->setText(format((long)uvmexp.swpages * uvmexp.pagesize));
    freeSwapMem->setText(format((long)(uvmexp.swpages - uvmexp.swpginuse) *
							uvmexp.pagesize));
    }
#else
  freeMem->setText(klocale->translate("Not calculated"));
  activeMem->setText(klocale->translate("Not calculated"));
  inactiveMem->setText(klocale->translate("Not calculated"));

  /* swap */
  totalswap = freeswap = usedswap = 0;
  nswap = swapctl(SWAP_NSWAP,0,0);
  if ( nswap > 0 )
    {
    if ( (swaplist = (struct swapent *)malloc(nswap * sizeof(*swaplist))) )
      {
      rnswap = swapctl(SWAP_STATS,swaplist,nswap);
      if ( rnswap < 0 || rnswap > nswap )
	totalswap = freeswap = -1;	/* Error */
      else
	{
	while ( rnswap-- > 0 )
	  {
	  totalswap += swaplist[rnswap].se_nblks;
	  usedswap += swaplist[rnswap].se_inuse;
	  }
	freeswap = totalswap - usedswap;
	}
      }
    else
      totalswap = freeswap = -1;	/* Error */
    if ( totalswap == -1 )
      {
      swapMem->setText(klocale->translate("Problem in determining"));
      freeSwapMem->setText(klocale->translate("Problem in determining"));
      }
    else
      {					/* Cast to long for LP64 hosts */
      swapMem->setText(format(dbtob((long)totalswap)));
      freeSwapMem->setText(format(dbtob((long)freeswap)));
      }
    }
#endif
}

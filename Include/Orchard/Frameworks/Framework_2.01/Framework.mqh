/*
 	Framework_2.00.mqh
 	
   Copyright 2013-2020, Orchard Forex
   https://www.orchardforex.com
 
 	
*/

//	History
//	1.00 - First version, not well version controlled
//	2.00 - Changed framework structure, functionally same as 1.00
// 2.01 - Added TP and SL


#ifndef _FRAMEWORK_VERSION_

	#define	_FRAMEWORK_VERSION_		"2.01"
	
	#include "CommonBase.mqh"
	
	#include	"Trade/Trade.mqh"

	#include "Indicators/Indicators.mqh"
	#include "Signals/Signals.mqh"
	#include "TPSL/TPSL.mqh"
	
	#include "ExpertBase.mqh"

	#include "../Extensions/AllExtensions.mqh"

#endif

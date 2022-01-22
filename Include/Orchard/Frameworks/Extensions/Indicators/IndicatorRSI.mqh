/*
 	IndicatorRSI.mqh
 	
   Copyright 2013-2020, Orchard Forex
   https://www.orchardforex.com
 
*/
 
#include	"../../Framework.mqh"

class CIndicatorRSI : public CIndicatorBase {

private:

protected:	// member variables

	int						mPeriods;
	ENUM_APPLIED_PRICE	mAppliedPrice;

public:	// constructors

	CIndicatorRSI(int periods, ENUM_APPLIED_PRICE appliedPrice)
								:	CIndicatorBase()
								{	Init(periods, appliedPrice);	}
	CIndicatorRSI(string symbol, ENUM_TIMEFRAMES timeframe,
						int periods, ENUM_APPLIED_PRICE appliedPrice)
								:	CIndicatorBase(symbol, timeframe)
								{	Init(periods, appliedPrice);	}
	~CIndicatorRSI();
	
	virtual int			Init(int periods, ENUM_APPLIED_PRICE appliedPrice);

public:

   virtual double GetData(const int buffer_num,const int index);

};

CIndicatorRSI::~CIndicatorRSI() {

}

int		CIndicatorRSI::Init(int periods, ENUM_APPLIED_PRICE appliedPrice) {

	if (InitResult()!=INIT_SUCCEEDED)	return(InitResult());
	
	mPeriods			=	periods;
	mAppliedPrice	=	appliedPrice;

#ifdef __MQL5__
	mIndicatorHandle			=	iRSI(mSymbol, mTimeframe, mPeriods, mAppliedPrice);
	if (mIndicatorHandle==INVALID_HANDLE)	return(InitError("Failed to create indicator handle", INIT_FAILED));
#endif

	return(INIT_SUCCEEDED);
	
}

double	CIndicatorRSI::GetData(const int buffer_num,const int index) {

	double	value	=	0;
#ifdef __MQL4__
	value	=	iRSI(mSymbol, mTimeframe, mPeriods, mAppliedPrice, index);
#endif

#ifdef __MQL5__
	double	bufferData[];
	ArraySetAsSeries(bufferData, true);
	int cnt	=	CopyBuffer(mIndicatorHandle, buffer_num, index, 1, bufferData);
	if (cnt>0) value	=	bufferData[0];
#endif

	return(value);
	
}



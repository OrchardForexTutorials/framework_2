/*
 	SignalTrend_2Indicators.mqh
 	For framework version 1.0
 	
   Copyright 2013-2020, Orchard Forex
   https://www.orchardforex.com
 
*/
 
#include	"../../Framework.mqh"

class CSignalTrend_2Indicator : public CSignalBase {

private:

protected:	// member variables

	int				mIndex;
	
public:	// constructors

	CSignalTrend_2Indicator(string symbol, ENUM_TIMEFRAMES timeframe,
								int index=1)
								:	CSignalBase(symbol, timeframe)
								{	Init(index);	}
	CSignalTrend_2Indicator(int index=1)
								:	CSignalBase()
								{	Init(index);	}
	~CSignalTrend_2Indicator()	{	}
	
	int			Init(int index);

public:

	virtual void								UpdateSignal();

};

int		CSignalTrend_2Indicator::Init(int index) {

	if (InitResult()!=INIT_SUCCEEDED)	return(InitResult());

	mIndex			=	index;
			
	return(INIT_SUCCEEDED);
	
}

void		CSignalTrend_2Indicator::UpdateSignal() {

	double	fast	=	GetIndicatorData(0, mIndex);
	double	slow	=	GetIndicatorData(1, mIndex);

	if ( fast>slow ) {	//	Up trend
		mEntrySignal	=	OFX_SIGNAL_BUY;
		mExitSignal		=	OFX_SIGNAL_SELL;
	} else
	if ( fast<slow ) {	//	Down trend
		mEntrySignal	=	OFX_SIGNAL_SELL;
		mExitSignal		=	OFX_SIGNAL_BUY;
	} else {
		mEntrySignal	=	OFX_SIGNAL_NONE;
		mExitSignal		=	OFX_SIGNAL_NONE;
	}

	return;
	
}

	

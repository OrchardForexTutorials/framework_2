/*
 	SignalTrend_1Indicator.mqh
 	
   Copyright 2013-2020, Orchard Forex
   https://www.orchardforex.com
 
*/
 
#include	"../../Framework.mqh"

class CSignalTrend_1Indicator : public CSignalBase {

private:

protected:	// member variables

	int				mIndex;
	double			mBuyLevel;
	double			mSellLevel;
	
public:	// constructors

	CSignalTrend_1Indicator(string symbol, ENUM_TIMEFRAMES timeframe,
								double buyLevel, double sellLevel, int index=1)
								:	CSignalBase(symbol, timeframe)
								{	Init(buyLevel, sellLevel, index);	}
	CSignalTrend_1Indicator(double buyLevel, double sellLevel, int index=1)
								:	CSignalBase()
								{	Init(buyLevel, sellLevel, index);	}
	~CSignalTrend_1Indicator()	{	}
	
	int			Init(double buyLevel, double sellLevel, int index);

public:

	virtual void								UpdateSignal();

};

int		CSignalTrend_1Indicator::Init(double buyLevel, double sellLevel, int index) {

	if (InitResult()!=INIT_SUCCEEDED)	return(InitResult());

	mBuyLevel		=	buyLevel;
	mSellLevel		=	sellLevel;
	mIndex			=	index;
			
	return(INIT_SUCCEEDED);
	
}

void		CSignalTrend_1Indicator::UpdateSignal() {

	double	value	=	GetIndicatorData(0, mIndex);

	if ( value>=mBuyLevel ) {	//	Up trend
		mEntrySignal	=	OFX_SIGNAL_BUY;
		mExitSignal		=	OFX_SIGNAL_SELL;
	} else
	if ( value<=mSellLevel ) {	//	Down trend
		mEntrySignal	=	OFX_SIGNAL_SELL;
		mExitSignal		=	OFX_SIGNAL_BUY;
	} else {
		mEntrySignal	=	OFX_SIGNAL_NONE;
		mExitSignal		=	OFX_SIGNAL_NONE;
	}

	return;
	
}

	

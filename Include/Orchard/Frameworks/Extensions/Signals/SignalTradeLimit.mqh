/*
 	SignalTradeLimit.mqh
 	
   Copyright 2013-2020, Orchard Forex
   https://www.orchardforex.com
 
*/
 
#include	"../../Framework.mqh"

class CSignalTradeLimit : public CSignalBase {

private:

	int mMagicNumber;
	int mBuyLimit;
	int mSellLimit;
	int mTotalLimit;

	CTradeCustom	Trade;

protected:	// member variables

public:	// constructors

	CSignalTradeLimit(string symbol,
								int magicNumber,
								int buyLimit=-1, int sellLimit=-1, int totalLimit=-1)
								:	CSignalBase(symbol, (ENUM_TIMEFRAMES)Period())
								{	Init(magicNumber, buyLimit, sellLimit, totalLimit);	}
	CSignalTradeLimit(int magicNumber,
								int buyLimit=-1, int sellLimit=-1, int totalLimit=-1)
								:	CSignalBase()
								{	Init(magicNumber, buyLimit, sellLimit, totalLimit);	}
	~CSignalTradeLimit()	{	}
	
	int			Init(int magicNumber, int buyLimit, int sellLimit, int totalLimit);

public:

	virtual void								UpdateSignal();

};

int		CSignalTradeLimit::Init(int magicNumber, int buyLimit, int sellLimit, int totalLimit) {

	if (InitResult()!=INIT_SUCCEEDED)	return(InitResult());

	mMagicNumber	=	magicNumber;
	mBuyLimit		=	buyLimit;
	mSellLimit		=	sellLimit;
	mTotalLimit		=	totalLimit;

	Trade.SetExpertMagicNumber(magicNumber);
			
	return(INIT_SUCCEEDED);
	
}

void		CSignalTradeLimit::UpdateSignal() {

	int	count[];
	int	buyCount;
	int	sellCount;
	
	Trade.PositionCountByType(mSymbol, count);
	buyCount		=	count[POSITION_TYPE_BUY];
	sellCount	=	count[POSITION_TYPE_SELL];
	
	ENUM_OFX_SIGNAL_DIRECTION	result	=	OFX_SIGNAL_BOTH;
	//	Are we over the total limit
	if (mTotalLimit>=0 && (buyCount+sellCount)>=mTotalLimit) {
		result	=	OFX_SIGNAL_NONE;
	} else
	//	Are we over both limits
	if ( (mBuyLimit>=0 && buyCount>=mBuyLimit) && (mSellLimit>=0 && sellCount>=mSellLimit) ) {
		result	=	OFX_SIGNAL_NONE;
	} else
	//	Are we just over the buy limit
	if (mBuyLimit>=0 && buyCount>=mBuyLimit) {
		result	=	OFX_SIGNAL_SELL;
	} else
	//	Are we just over the sell limit
	if (mSellLimit>=0 && sellCount>=mSellLimit) {
		result	=	OFX_SIGNAL_BUY;
	}

	mEntrySignal	=	result;
	mExitSignal		=	OFX_SIGNAL_NONE;	//	Does not trigger exits

	return;
	
}

	

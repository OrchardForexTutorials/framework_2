/*
	ExpertBase.mqh

	Copyright 2013-2020, Orchard Forex
	https://www.orchardforex.com

*/


#include	"CommonBase.mqh"
#include "Signals/SignalBase.mqh"
#include "TPSL/TPSLBase.mqh"
#include	"Trade/Trade.mqh"

class CExpertBase : public CCommonBase {

protected:

	int				mMagicNumber;
	string			mTradeComment;
	
	double			mVolume;
	
	datetime			mLastBarTime;
	datetime			mBarTime;
	
	CSignalBase		*mEntrySignal;
	CSignalBase		*mExitSignal;

	double			mTakeProfitValue;
	double			mStopLossValue;
	CTPSLBase		*mTakeProfitObj;
	CTPSLBase		*mStopLossObj;
	
	CTradeCustom	Trade;

private:

protected:

	virtual bool	LoopMain(bool newBar, bool firstTime);
	
protected:

	int				Init(int magicNumber, string tradeComment);

public:

	//
	//	Constructors
	//
	CExpertBase()							: CCommonBase()
												{	Init(0, "");	}
	CExpertBase(string symbol, int timeframe, int magicNumber, string tradeComment)
												:	CCommonBase(symbol, timeframe)
												{	Init(magicNumber, tradeComment);	}
	CExpertBase(string symbol, ENUM_TIMEFRAMES timeframe, int magicNumber, string tradeComment)
												:	CCommonBase(symbol, timeframe)
												{	Init(magicNumber, tradeComment);	}
	CExpertBase(int magicNumber, string tradeComment)
												:	CCommonBase()
												{	Init(magicNumber, tradeComment);	}

	//
	//	Destructors
	//
	~CExpertBase();

public:	//	Default properties

	//
	//	Assign the default values to the expert
	//
	virtual void	SetVolume(double volume)		{	mVolume			=	volume;	}

	virtual void	SetTakeProfitValue(int takeProfitPoints)
																{	mTakeProfitValue	=	PointsToDouble(takeProfitPoints);	}
	virtual void	SetTakeProfitObj(CTPSLBase *takeProfitObj)
																{	mTakeProfitObj	=	takeProfitObj;	}

	virtual void	SetStopLossValue(int stopLossPoints)
																{	mStopLossValue	=	PointsToDouble(stopLossPoints);	}
	virtual void	SetStopLossObj(CTPSLBase *stopLossObj)
																{	mStopLossObj	=	stopLossObj;	}
	
	virtual void	SetTradeComment(string comment)	{	mTradeComment	=	comment;	}
	virtual void	SetMagic(int magicNumber)			{	mMagicNumber	=	magicNumber;
																		Trade.SetExpertMagicNumber(magicNumber);	}

public:	//	Setup

	virtual void	AddEntrySignal(CSignalBase *signal)	{	mEntrySignal=signal;	}
	virtual void	AddExitSignal(CSignalBase *signal)	{	mExitSignal=signal;	}
	
public:	//	Event handlers

	virtual int		OnInit()				{	return(InitResult());	}
	virtual void	OnTick();
	virtual void	OnTimer()			{	return;	}
	virtual double	OnTester()			{	return(0.0);	}
	virtual void	OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {};

#ifdef __MQL5__
	virtual void	OnTrade()			{	return;	}
	virtual void	OnTradeTransaction(const MqlTradeTransaction& trans,
                        					const MqlTradeRequest& request,
                        					const MqlTradeResult& result)
                        				{	return;	}
	virtual void	OnTesterInit()		{	return;	}
	virtual void	OnTesterPass()		{	return;	}
	virtual void	OnTesterDeinit()	{	return;	}
	virtual void	OnBookEvent()		{	return;	}
#endif

public:	// Functions

	virtual void	GetMarketPrices(ENUM_ORDER_TYPE orderType, MqlTradeRequest &request);
	
};

CExpertBase::~CExpertBase() {

}

int	CExpertBase::Init(int magicNumber, string tradeComment) {

	if (mInitResult!=INIT_SUCCEEDED) return(mInitResult);
	
	mTradeComment		=	tradeComment;
	SetMagic(magicNumber);

	mTakeProfitValue	=	0.0;
	mStopLossValue		=	0.0;
		
	mLastBarTime		=	0;
	
	return(INIT_SUCCEEDED);
	
}

void	CExpertBase::OnTick(void) {

	if (!TradeAllowed()) return;
	
	mBarTime	=	iTime(mSymbol, mTimeframe, 0);

	bool	firstTime	=	(mLastBarTime==0);
	bool	newBar		=	(mBarTime!=mLastBarTime);
	
	if (LoopMain(newBar, firstTime)) {
		mLastBarTime	=	mBarTime;
	}

	return;
	
}

bool		CExpertBase::LoopMain(bool newBar,bool firstTime) {

	//
	//	To start I will only trade on a new bar
	//		and not on the first bar after start
	//
	if (!newBar)	return(true);
	if (firstTime)	return(true);
	
	//
	//	Update the signals
	//
	if (mEntrySignal!=NULL)	mEntrySignal.UpdateSignal();
	if (mEntrySignal!=mExitSignal) {
		if (mExitSignal!=NULL)	mExitSignal.UpdateSignal();
	}
	
	//
	//	Should any trades be closed
	//
	if (mExitSignal!=NULL) {
		if (mExitSignal.ExitSignal()==OFX_SIGNAL_BOTH) {
			Trade.PositionCloseByType(mSymbol, POSITION_TYPE_BUY);
			Trade.PositionCloseByType(mSymbol, POSITION_TYPE_SELL);
		} else
		if (mExitSignal.ExitSignal()==OFX_SIGNAL_BUY) {
			Trade.PositionCloseByType(mSymbol, POSITION_TYPE_BUY);
		} else
		if (mExitSignal.ExitSignal()==OFX_SIGNAL_SELL) {
			Trade.PositionCloseByType(mSymbol, POSITION_TYPE_SELL);
		}
	}
	
	//
	//	Should a trade be opened
	//
	MqlTradeRequest	request = {0};
	//if (mStopLoss!=0 || mTakeProfit!=0
	if (mEntrySignal!=NULL) {
		if (mEntrySignal.EntrySignal()==OFX_SIGNAL_BOTH) {

			GetMarketPrices(ORDER_TYPE_BUY, request);
			Trade.Buy(mVolume, mSymbol, request.price, request.sl, request.tp);

			GetMarketPrices(ORDER_TYPE_SELL, request);
			Trade.Sell(mVolume, mSymbol, request.price, request.sl, request.tp);

		} else
		if (mEntrySignal.EntrySignal()==OFX_SIGNAL_BUY) {

			GetMarketPrices(ORDER_TYPE_BUY, request);
			Trade.Buy(mVolume, mSymbol, request.price, request.sl, request.tp);

		} else
		if (mEntrySignal.EntrySignal()==OFX_SIGNAL_SELL) {

			GetMarketPrices(ORDER_TYPE_SELL, request);
			Trade.Sell(mVolume, mSymbol, request.price, request.sl, request.tp);

		}
	}
	
	return(true);
	
}

void	CExpertBase::GetMarketPrices(ENUM_ORDER_TYPE orderType, MqlTradeRequest &request) {

	double	sl	=	(mStopLossObj==NULL) ? mStopLossValue : mStopLossObj.GetStopLoss();
	double	tp	=	(mTakeProfitObj==NULL) ? mTakeProfitValue : mTakeProfitObj.GetTakeProfit();
	
	if (orderType==ORDER_TYPE_BUY) {
		if (request.price==0.0) request.price	=	SymbolInfoDouble(mSymbol, SYMBOL_ASK);
		request.tp	=	(tp==0.0) ? 0.0 : NormalizeDouble(request.price+tp, mDigits);
		request.sl	=	(sl==0.0) ? 0.0 : NormalizeDouble(request.price-sl, mDigits);
	}

	if (orderType==ORDER_TYPE_SELL) {
		if (request.price==0.0) request.price	=	SymbolInfoDouble(mSymbol, SYMBOL_BID);
		request.tp	=	(tp==0.0) ? 0.0 : NormalizeDouble(request.price-tp, mDigits);
		request.sl	=	(sl==0.0) ? 0.0 : NormalizeDouble(request.price+sl, mDigits);
	}

	return;

}


	





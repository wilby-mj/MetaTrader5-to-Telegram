//+------------------------------------------------------------------+
//|                                                MT5toTelegram.mq5 |
//|              Copyright 2021, Kiganjani Technologies Company Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
   #property copyright "Copyright 2021, Kiganjani Technologies Company Ltd."
   #property link      "https://www.mql5.com"
   #property version   "1.00"
   
   #property strict
   #include <Telegram.mqh>

//+------------------------------------------------------------------+
//| CMyBot                                                           |
//+------------------------------------------------------------------+

   class CMyBot: public CCustomBot{
   
         public: void ProcessMessages(void){
         
               for(int i=0; i<m_chats.Total(); i++){
               
                  CCustomChat *chat=m_chats.GetNodeAtIndex(i);
                  
                  //--- If Message is not Processed
                  if(!chat.m_new_one.done){
                  
                     chat.m_new_one.done = true;
                     string text=chat.m_new_one.message_text;
                     
                     //-- Start
                     if(text=="/start")
                        SendMessage(chat.m_id, "Hello, I am FX four_The$20s Bot.\n\n For more information reply to this message with /help");
                        
                     //-- Help
                     if(text=="/help")
                        SendMessage(chat.m_id,"FAQ \n ");
                     }
                     
                  }
                  
               }
               
            };
   
   input string InpChannelName ="";       //Channel Name
   input string InpToken       ="";       //Bot Token
   //input long   ChatID         ="";
   
   CMyBot bot;
   int getme_result;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

   int OnInit()
     {
      //Set Token
      bot.Token(InpToken);
      
      //Check Token          
      getme_result=bot.GetMe();     
      
      //Run Timer
      EventSetTimer(3);             
      OnTimer();
      
      return(INIT_SUCCEEDED);
     }
  
  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+

   void OnDeinit(const int reason)
     {
      Comment("");
     }
     
  
//+------------------------------------------------------------------+
//| OnTimer                                                          |
//+------------------------------------------------------------------+

   void OnTimer()
     {
         //--- Show Error Message and Exit
         if(getme_result!=0){
            Comment("Error: ",GetErrorDescription(getme_result));
            return;
            }
      
         //--- Show Bot Name
         Comment("Bot Name: ",bot.Name());
         
         //--- Reading Messages
         bot.GetUpdates();
         
         //--- Processing Messages
         bot.ProcessMessages();   
     }
  
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
   void OnTick()
     {
     
      //--- get time
      datetime time[1];
      if(CopyTime(NULL,0,0,1,time)!=1)
         return;
     }


//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
   void OnTradeTransaction(const MqlTradeTransaction &trans, const MqlTradeRequest &request, const MqlTradeResult &result)
      {
      
      // Transaction Details
      ENUM_TRADE_TRANSACTION_TYPE transaction_type = trans.type;
      
         // Orders
         ulong order_ID = trans.order;
         ENUM_ORDER_TYPE  order_type = trans.order_type;       // Order type         
         ENUM_ORDER_STATE order_state = trans.order_state;      // Order state     
            
         // Deals
         ulong deal_ID = trans.deal;
         ENUM_DEAL_TYPE deal_type = trans.deal_type;
         
         //Positions
         ulong position_ID = trans.position; 
      
      // Price Levels
      string trade_symbol = trans.symbol;    //--- the name of the symbol, for which a transaction was performed
      double lot_size = trans.volume;
      double entry_price = trans.price;
      double stop_loss = trans.price_sl;
      double take_profit = trans.price_tp;
      
       
      //ORDER
         // Orders are trades that are yet to be executed. The EA should send these pending orders to the channel via the Bot.
         
         
               if(transaction_type = TRADE_TRANSACTION_ORDER_ADD || TRADE_TRANSACTION_ORDER_UPDATE || TRADE_TRANSACTION_ORDER_DELETE){
                  string msg=StringFormat("NEW ORDER \nOrder Number: %s \nSymbol: %S \nOrder Type: %s \nLot Size: %s \n",
                                                                    order_ID, trade_symbol, order_type, lot_size);
                     
                     // Send Signal to named Channel                        
                     int res=bot.SendMessage(InpChannelName,msg);
                     if(res!=0)
                        Print("Error: ",GetErrorDescription(res));      
                  }
               
                     // BUY
                     if(order_type = ORDER_TYPE_BUY || ORDER_TYPE_BUY_LIMIT || ORDER_TYPE_BUY_STOP){
                        string msg=StringFormat("Trade Signal \nSymbol: %s \nOrder Type: %s \nEntry Price: %s \nStop Loss: %s \nTake Profit: %s",
                                                                trade_symbol, order_type, entry_price, stop_loss, take_profit);
                           
                           // Send Signal to named Channel                        
                           int res=bot.SendMessage(InpChannelName,msg);
                           if(res!=0)
                              Print("Error: ",GetErrorDescription(res));
                        }
                        
                      // SELL
                      if(order_type = ORDER_TYPE_SELL || ORDER_TYPE_SELL_LIMIT || ORDER_TYPE_SELL_STOP){
                        string msg=StringFormat("Trade Signal \nSymbol: %s \nOrder Type: %s \nEntry Price: %s \nStop Loss: %s \nTake Profit: %s",
                                                                trade_symbol, order_type, entry_price, stop_loss, take_profit);
                           
                           // Send Signal to named Channel                        
                           int res=bot.SendMessage(InpChannelName,msg);
                           if(res!=0)
                              Print("Error: ",GetErrorDescription(res));
                        }
               
               if(order_state = ORDER_STATE_PLACED || ORDER_STATE_FILLED || ORDER_STATE_CANCELED){
                  string msg=StringFormat("NEW ORDER \nOrder Number: %s \nSymbol: %S \nOrder Type: %s \nLot Size: %s \n",
                                                                    order_ID, trade_symbol, order_type, lot_size);
                     
                     // Send Signal to named Channel                        
                     int res=bot.SendMessage(InpChannelName,msg);
                     if(res!=0)
                        Print("Error: ",GetErrorDescription(res));      
                  }
      //DEAL
         // Deals are the execution of trades. The EA should send notifications of trades being executed to the channel.
         
         
            if(transaction_type = TRADE_TRANSACTION_DEAL_ADD || TRADE_TRANSACTION_DEAL_UPDATE || TRADE_TRANSACTION_DEAL_DELETE){
                  string msg=StringFormat("NEW TRADE ACTIVITY \nSymbol: %S \nOrder Type: %s \nLot Size: %s \n",
                                                                trade_symbol, order_type, lot_size);
                     
                     // Send Signal to named Channel                        
                     int res=bot.SendMessage(InpChannelName,msg);
                     if(res!=0)
                        Print("Error: ",GetErrorDescription(res));      
               }
         
         // BUY
         if(deal_type = DEAL_TYPE_BUY){
            string msg=StringFormat("Trade Signal \nSymbol: %s \nOrder Type: %s \nEntry Price: %s \nStop Loss: %s \nTake Profit: %s",
                                       trade_symbol, order_type, entry_price, stop_loss, take_profit);
               
               // Send Signal to named Channel                        
               int res=bot.SendMessage(InpChannelName,msg);
               if(res!=0)
                  Print("Error: ",GetErrorDescription(res));
            }
            
          // SELL  
          if(deal_type = DEAL_TYPE_SELL){
            string msg=StringFormat("Trade Signal \nSymbol: %s \nOrder Type: %s \nEntry Price: %s \nStop Loss: %s \nTake Profit: %s",
                                       trade_symbol, order_type, entry_price, stop_loss, take_profit);
               
               // Send Signal to named Channel                        
               int res=bot.SendMessage(InpChannelName,msg);
               if(res!=0)
                  Print("Error: ",GetErrorDescription(res));
            }  
            
      // POSITION
         //Positions are open trades. The purpose of this functtion is to notify users on changes such as trailing stops.
         
           if(transaction_type = TRADE_TRANSACTION_POSITION) 
           {
            string msg=StringFormat("Position Update: Position  #%d %s \nSymbol: %s \nNew Levels: SL=%.5f TP=%.5f",
                                                         position_ID,trade_symbol,stop_loss,take_profit);
            
            // Send Signal to named Channel                        
               int res=bot.SendMessage(InpChannelName,msg);
               if(res!=0)
                  Print("Error: ",GetErrorDescription(res));            
           } 
      }
//+------------------------------------------------------------------+                        
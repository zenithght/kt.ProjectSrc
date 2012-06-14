package game.module.searchTreasure {
	import flash.display.Bitmap;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import game.config.StaticConfig;
	import game.core.user.StateManager;
	import game.core.user.UserData;
	import game.module.mapClanBossWar.MCBWController;
	import game.net.core.Common;
	import game.net.data.CtoS.CSGDLeave;
	import game.net.data.CtoS.CSGDPlayerState;
	import game.net.data.CtoS.CSGDRebirth;
	import game.net.data.StoC.SCGDBattleResult;
	import game.net.data.StoC.SCGDBegin;
	import game.net.data.StoC.SCGDBossInfo;
	import game.net.data.StoC.SCGDEnter;
	import game.net.data.StoC.SCGDEnter.GDPlayer;
	import game.net.data.StoC.SCGDFinish;
	import game.net.data.StoC.SCGDLeave;
	import game.net.data.StoC.SCGDPlayerEnter;
	import game.net.data.StoC.SCGDReBirth;
	import game.net.data.StoC.SCGDStateList;
	import game.net.data.StoC.SCGDStateList.GuildBossPlayerState;
	import net.AssetData;
	import net.LibData;
	import net.RESManager;
//	import game.net.data.StoC.SCGDTime;

	/**
	 * @author Lv
	 */
	public class ProxySearchTreasure extends EventDispatcher {
		//boss的总血量
		public static var bossTotalBlood:int;
		//boss的剩余血量
		public static var bossRestBlood:int;
		//boss的ID
		public static var bossID:int;
		//boss的等级
		public static var bossLevel:int;
		//家族副本战争的时间
		public static var warTimer:uint;
		
		//玩家复活需要的钱币
		public static var playerReliveGold:int;
		//玩家复活的时间
		public static var playerReliveTimer:uint;
		
		//boss跳血资源
		public static var bossBloodVec:Vector.<Bitmap> = new Vector.<Bitmap>();
		
		public function ProxySearchTreasure(singleton : proxy, target : IEventDispatcher = null) {
			singleton;
			super(target);
			sToc();
		}

        /** 单例对像 */
        private static var _instance : ProxySearchTreasure;

        /** 获取单例对像 */
        static public function get instance() : ProxySearchTreasure
        {
            if (_instance == null)
            {
                _instance = new ProxySearchTreasure(new proxy());
            }
            return _instance;
        }
		
		private function get uiController() : SearchTreasureControl
        {
            return SearchTreasureControl.instance;
        }
		
		public function get mapController():MCBWController
        {
            return MCBWController.instance;
        }
		
		private function sToc() : void {
			//家族副本开启
			Common.game_server.addCallback(0xF1, sCGDBegin);
			//玩家进入家族副本
			Common.game_server.addCallback(0xF2, sCGDEnter);
			//有玩家进入家族副本
			Common.game_server.addCallback(0xF3, sCGDPlayerEnter);
			//副本里的战斗结果
			Common.game_server.addCallback(0xF4, sCGDBattleResult);
			//家族副本玩家状态
			Common.game_server.addCallback(0xF5, sCGDStateList);
			//家族寻宝Boss信息
			Common.game_server.addCallback(0xF6, sCGDBossInfo);
			//离开副本
			Common.game_server.addCallback(0xF7, sCGDLeave);
			//副本结束
			Common.game_server.addCallback(0xF11, sCGDFinish);
			//金币复活
			Common.game_server.addCallback(0xF9, sCGDReBirth);
		}
		//金币复活
		private function sCGDReBirth(e:SCGDReBirth) : void {
			var id:int = UserData.instance.playerId;
			if(e.result == 0)
				StateManager.instance.checkMsg(4);
			else
				mapController.revive(id);
		}
		//副本结束
		private function sCGDFinish(e:SCGDFinish) : void {
			uiController.uninstallUI();
			clearnLoaderBloodNum();
		}

		//离开副本
		private function sCGDLeave(e:SCGDLeave) : void {
			var id:int = UserData.instance.playerId;
			if(e.player == id){
				uiController.uninstallUI();
				clearnLoaderBloodNum();
			}
		}
		//家族寻宝Boss信息
		private function sCGDBossInfo(e:SCGDBossInfo) : void {
			if(e.hasBossmaxhp)
				bossTotalBlood = e.bossmaxhp;
			if(e.hasBossnowhp)
				bossRestBlood = e.bossnowhp;
			if(e.hasDeadtime)
				warTimer = e.deadtime;
			if(e.hasBossid)
				bossID = e.bossid;
			if(e.hasBosslevel){
				bossLevel = e.bosslevel;
				uiController.setBossTimer();
			}
			
		}
		//家族副本玩家状态
		private function sCGDStateList(e:SCGDStateList) : void {
			var list:Vector.<GuildBossPlayerState> = e.playerstatelist;
			for each(var playerState:GuildBossPlayerState in list){
				if(playerState.hasGoldnum)
					playerReliveGold = playerState.goldnum;
				if(playerState.hasLefttime)
					playerReliveTimer = playerState.lefttime;
				//玩家状态0:普通 1：未复活
				if(playerState.state == 1)
				{
					mapController.die(playerState.playerid);
					if(playerState.playerid == UserData.instance.playerId)
						uiController.setReviveTime(playerReliveTimer);
				}else{
					mapController.revive(playerState.playerid);
					if(playerState.playerid == UserData.instance.playerId)
						uiController.stopReviveTime();
				}
			}
		}
		//副本里的战斗结果
		private function sCGDBattleResult(e:SCGDBattleResult) : void {
			ProxySearchTreasure.bossRestBlood = e.lefthp;
			uiController.refreshBossBlood(e.dmg);
			var uin:int;
			SearchTreasureControl.playerHarmToBossList[e.player].dmg =  SearchTreasureControl.playerHarmToBossList[e.player].dmg + e.dmg;
			uin = SearchTreasureControl.playerHarmToBossList[e.player].dmg;
			rankingList();
			uiController.setHarmToBossList();
		}
		//有玩家进入家族副本
		private function sCGDPlayerEnter(e:SCGDPlayerEnter) : void {
			if(e.player == UserData.instance.playerId)return;
			var obj:Object = new Object();
			obj.dmg = 0;
			obj.name = e.name;
			obj.color = e.color; 
			if(SearchTreasureControl.playerHarmToBossList[e.player])return;
			SearchTreasureControl.playerHarmToBossList[e.player] = obj;
			SearchTreasureControl.playerharmListVec.push(obj);
			rankingList();
		}
		//玩家进入家族副本
		private function sCGDEnter(e:SCGDEnter) : void {
			if(SearchTreasureControl.playerharmListVec.length>0)clearnMC();
			var list:Vector.<GDPlayer> = e.playerlist;
			for each(var player:GDPlayer in list){
				var k:int = player.player;
				var obj:Object = new Object();
				obj.name = player.name;
				obj.dmg = player.dmg;
				obj.color = player.color;
				SearchTreasureControl.playerHarmToBossList[k] = obj;
				SearchTreasureControl.playerharmListVec.push(obj);
				//当前状态(0:普通 1：未复活)
				var stat:int = player.state;
				if(stat == 1){
					mapController.die(k);
					if(k == UserData.instance.playerId){
						uiController.setReviveTime(playerReliveTimer);
					}
				}
				
			}
			rankingList();
			uiController.setHarmToBossList();
		}
		//家族副本开启
		private function sCGDBegin(e:SCGDBegin) : void {
			switch(e.flag){
				case 0:
					//0表示boss战未开始
					break;
				case 1:
					//1表示boss出现
					break;
				case 2:
					uiController.join();
					loaderBloodNum();
					//2表示boss战正式开始
					break;
				case 3:
					uiController.join();
					loaderBloodNum();
					//3表示boss战进行中
					break;
			}
		}
//-----------------------------------------------------------------------------------
		//申请退出地穴
		public function outToCrypt():void
		{
			var cmd:CSGDLeave = new CSGDLeave();
			Common.game_server.sendMessage(0xF6,cmd);
		}
		//申请复活
		public function myPlayerReLive():void{
			var cmd:CSGDPlayerState = new CSGDPlayerState();
			Common.game_server.sendMessage(0xF4,cmd);
		}
		//金币复活
		public function goldPlayerRelive():void{
			var cmd:SCGDReBirth = new SCGDReBirth();
			Common.game_server.sendMessage(0xF9,cmd);
		}
//---------------------------------------------------------------------------------
		//排序		
		private function rankingList() : void {
			SearchTreasureControl.playerharmListVec.sort(rank);
		}
		private function rank(a:Object,b:Object):Number{
			return -a.dmg + b.dmg;
		}
		 /**
         * 加载跳血资源
         */
        public function loaderBloodNum():void{
            RESManager.instance.load(new LibData(StaticConfig.cdnRoot + "assets/ui/numberTest.swf", "bossNum"), initDieFrame);
        }

        private function initDieFrame() : void
        {
            for(var  i:int = 0; i < 12; i++ )
			{
				if(i == 0)
					bossBloodVec[i] = new Bitmap(RESManager.getBitmapData(new AssetData("Number_Hurt_a", "bossNum")));
				else if(i == 1)
					bossBloodVec[i] = new Bitmap(RESManager.getBitmapData(new AssetData("Number_Hurt_b", "bossNum")));
				else 
					bossBloodVec[i] = new Bitmap(RESManager.getBitmapData(new AssetData("Number_Hurt_" + (i-2).toString(), "bossNum")));
			}
        }
        /**
         * 清空跳血资源 和上次列表记录
         */
        public function clearnLoaderBloodNum():void{
            while (bossBloodVec.length != 0)
            {
                bossBloodVec.splice(0, 1);
            }
			
			while(SearchTreasureControl.playerharmListVec.length>0){
				SearchTreasureControl.playerharmListVec.splice(0, 1);
			}
        }
		//清空Obj
		private function clearnMC() : void {
			while(SearchTreasureControl.playerharmListVec.length>0){
				SearchTreasureControl.playerharmListVec.splice(0, 1);
			}
			for(var k:String in SearchTreasureControl.playerHarmToBossList)
			{
				delete  SearchTreasureControl.playerHarmToBossList[k];
			}
		}
	}
}
class proxy{}
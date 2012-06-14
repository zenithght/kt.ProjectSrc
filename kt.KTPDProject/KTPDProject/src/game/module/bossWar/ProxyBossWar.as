package game.module.bossWar {
	import flash.display.Bitmap;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import framerate.SecondsTimer;
	import game.config.StaticConfig;
	import game.core.user.StateManager;
	import game.core.user.UserData;
	import game.module.map.utils.MapUtil;
	import game.net.core.Common;
	import game.net.data.CtoS.CSBossAttack;
	import game.net.data.CtoS.CSBossEnter;
	import game.net.data.CtoS.CSBossLeave;
	import game.net.data.CtoS.CSBossPlayerStateList;
	import game.net.data.CtoS.CSBossReBirth;
	import game.net.data.StoC.BossDmgInfo;
	import game.net.data.StoC.BossPlayerState;
	import game.net.data.StoC.SCBossBsInfo;
	import game.net.data.StoC.SCBossDmglist;
	import game.net.data.StoC.SCBossFightBegin;
	import game.net.data.StoC.SCBossFightEnd;
	import game.net.data.StoC.SCBossLeaveReturn;
	import game.net.data.StoC.SCBossPlayerDmg;
	import game.net.data.StoC.SCBossPlayerStateList;
	import game.net.data.StoC.SCBossReBirth;
	import log4a.Logger;
	import net.AssetData;
	import net.LibData;
	import net.RESManager;






	/**
	 * @author Lv
	 */
	public class ProxyBossWar extends EventDispatcher {
		// Boss信息
		public static var bossBloodTotal : Number;
		public static var bossID : int;
		public static var bossBloodNow : uint;
		public static var bossLevel : int;
		public static var bossHarmValue : Number;
		// boss战计时时间记录
		public static var bossWarData : uint;
		public static var bossBloodVec : Vector.<Bitmap> = new Vector.<Bitmap>();
		// 快速复活的价格
		public static var revivePic : int;

		public function ProxyBossWar(singleton : proxy, target : IEventDispatcher = null) {
			singleton;
			super(target);
			sToC();
		}

		/** 单例对像 */
		private static var _instance : ProxyBossWar;

		/** 获取单例对像 */
		static public function get instance() : ProxyBossWar {
			if (_instance == null) {
				_instance = new ProxyBossWar(new proxy());
			}
			return _instance;
		}

		private function get bossWarControl() : BossWarControl {
			return BossWarControl.instance;
		}

		/**
		 * 监听协议
		 */
		private function sToC() : void {
			// 0x2e0 boss战开始
			Common.game_server.addCallback(0x2e0, scBossFightBegin);
			// boss战boss信息
			Common.game_server.addCallback(0x2e2, sCBossBsInf);
			// boss战伤害排名
			Common.game_server.addCallback(0x2e1, sCBossDmglist);
			// 某玩家对boss的累积伤害
			Common.game_server.addCallback(0x2e3, sCBossPlayerDmg);
			// boss战玩家状态
			Common.game_server.addCallback(0x2e6, sCBossPlayerStateList);
			// 离开boss战
			Common.game_server.addCallback(0x2e7, sCBossLeaveReturn);
			//boss战结束
			Common.game_server.addCallback(0x2e8, sCBossFightEnd);
			// 金币 快速复活
			Common.game_server.addCallback(0x2e5, sCBossReBirth);
		}
		// 离开boss战
		private function sCBossLeaveReturn(e:SCBossLeaveReturn) : void {
			bossWarControl.sc_quit();
		}

		// 金币 快速复活
		private function sCBossReBirth(e : SCBossReBirth) : void {
			var id : int = BossWarControl.myHeroID;
			if (e.hasResult) {
				if (e.result == 0) // 金币不足
				{
					StateManager.instance.checkMsg(4);
				} else {
					bossWarControl.bossWarPlayerStaticRelive(id);
				}
			}
		}

		//boss战结束
		private function sCBossFightEnd(e : SCBossFightEnd) : void {
			bossWarControl.playerToBossHarmList();
			bossWarControl.sc_close();
			clearnMc();
			clearnLoaderBloodNum();
			ProxyBossWar.bossHarmValue = 0;
			ProxyBossWar.bossBloodTotal = 0;
			ProxyBossWar.bossBloodNow = 0;
		}

		/**
		 * boss战开始
		 */
		private function scBossFightBegin(e : SCBossFightBegin) : void {
			if( !MapUtil.isBossWarMap() )
			{
				return ;
			}
			// 0表示boss出现，1表示boss战正式开始，2表示boss战未开始
			var warID : int = e.flag;
			switch(warID) {
				case 0:
					// 表示boss战未开始
					// bossWarControl.sc_close();
					break;
				case 1:
					break;
				case 2:
					// 表示boss战正式开始
					bossWarControl.bossWarTiemrStar();
					loaderBloodNum();
					bossWarControl.cs_join();
					
					break;
				case 3:
					// 表示boss战进行中
					bossWarControl.bossWarTiemrStar();
					loaderBloodNum();
					bossWarControl.cs_join();
					
					break;
				default :
					// 表示boss出现
					bossWarControl.bossWarTiemrStar();
					// bossWarControl.sc_open();
					loaderBloodNum();
				
			}
		}

		/**
		 * boss战玩家状态
		 */
		private function sCBossPlayerStateList(e : SCBossPlayerStateList) : void {
			var listVec : Vector.<BossPlayerState> = e.playerstatelist;
			var max : int = listVec.length;
			if (max == 0) return;
			var myId:int = UserData.instance.myHero.id;
			for each (var stat:BossPlayerState in listVec) {
				var id : int = stat.playerid;
				var foun : int = stat.state;
				if (foun == 1)  // 死亡
				{
					if (stat.hasGoldnum)
						revivePic = stat.goldnum;
					BossWarControl.hasMyPlayerDieTimer = stat.hasFlag;
					if(!stat.hasFlag){
						if (stat.hasLefttime)
							BossWarControl.myPlayerDieTimer = stat.lefttime;
					}
					bossWarControl.bossWarPalyerStaticDie(id);
					return;
				} else if (foun == 0)  // 复活
				{
					if (id == UserData.instance.playerId) {
						bossWarControl.bossWarPlayerStaticRelive(id);
					}
					return;
				}
			}
		}

		/**
		 * 玩家自己对boss的伤害
		 */
		private function sCBossPlayerDmg(e : SCBossPlayerDmg) : void {
			BossWarControl.mypalyeToBossHarm = e.totaldmg;
			bossWarControl.myPalyerHarmBoss();
		}

		/**
		 * 获取玩家对boss伤害的列表
		 */
		private function sCBossDmglist(e : SCBossDmglist) : void {
			if (BossWarControl.joinBossWarPlayerName.length != 0) clearnMc();
			var listVec : Vector.<BossDmgInfo> = e.dmglist;
			var nameVec : Vector.<String> = BossWarControl.joinBossWarPlayerName;
			var colorVec : Vector.<uint> = BossWarControl.joinBossWarPlayerColor;
			var harmVec : Vector.<uint> = BossWarControl.joinBossWarPlayerBlood;
			for each (var list:BossDmgInfo in listVec) {
				nameVec.push(list.playername);
				colorVec.push(list.color);
				harmVec.push(list.dmg);
			}
//			if(bossBloodVec.length<1)loaderBloodNum();
			bossWarControl.bossHarmRowList();
		}

		/**
		 * 申请boss数据
		 */
		private function sCBossBsInf(e : SCBossBsInfo) : void {
			if (e.hasBossid)
				ProxyBossWar.bossID = e.bossid;
			if (e.hasBossmaxhp)
				ProxyBossWar.bossBloodTotal = e.bossmaxhp;
			if (e.hasBosslevel)
				ProxyBossWar.bossLevel = e.bosslevel;
			if (e.hasBossdmg) {
				ProxyBossWar.bossHarmValue = e.bossdmg;
				bossWarControl.bossBloodControl();
			}
			if (e.hasDeadtime) {
				ProxyBossWar.bossWarData = e.deadtime;
				// 控制客户端boss战时间一直处于准确状态
				controlTimer();
				bossWarControl.timer();
			}
			ProxyBossWar.bossBloodNow = e.bosshpnow;
			bossWarControl.bossWarTimerShow();
		}

		// 控制客户端boss战时间一直处于准确状态
		private function controlTimer() : void {
			SecondsTimer.addFunction(refershTimer);
			// 倒计时控制
		}

		private function refershTimer() : void {
			if (ProxyBossWar.bossWarData == 0) {
				return;
			}
			ProxyBossWar.bossWarData--;
		}

		// ------------------------申请协议-------------------------------------------------------------
		public function bossWarGoldRelive() : void {
			var cmd : CSBossReBirth = new CSBossReBirth();
			cmd.flag = 1;
			Common.game_server.sendMessage(0x2e5, cmd);
		}

		// 玩家自己重生
		public function myPlayerRelive() : void {
			var cmd : CSBossPlayerStateList = new CSBossPlayerStateList();
			Common.game_server.sendMessage(0x2e6, cmd);
		}

		// 攻击boss
		public function attackBoss() : void {
			var cmd : CSBossAttack = new CSBossAttack();
			cmd.id = ProxyBossWar.bossID;
			Common.game_server.sendMessage(0x2e4, cmd);
		}

		// 参加boss战
		public function joyInBossWar() : void {
			var cmd : CSBossEnter = new CSBossEnter();
			Common.game_server.sendMessage(0x2E0, cmd);
		}

		// 退出boss战
		public function quickBossWar() : void {
			var cmd : CSBossLeave = new CSBossLeave();
			Common.game_server.sendMessage(0x2E7, cmd);
		}

		// -------------------------------------------------------------------------------------
		/**
		 * 清空boss血量伤害列表
		 */
		private function clearnMc() : void {
			while (BossWarControl.joinBossWarPlayerName.length != 0) {
				BossWarControl.joinBossWarPlayerName.splice(0, 1);
				BossWarControl.joinBossWarPlayerColor.splice(0, 1);
				BossWarControl.joinBossWarPlayerBlood.splice(0, 1);
			}
		}

		/**
		 * 加载跳血资源
		 */
		public function loaderBloodNum() : void {
			RESManager.instance.load(new LibData(StaticConfig.cdnRoot + "assets/ui/numberTest.swf", "bossNum"), initDieFrame);
		}

		private function initDieFrame() : void {
			for (var  i : int = 0; i < 12; i++ ) {
				if (i == 0)
					bossBloodVec[i] = new Bitmap(RESManager.getBitmapData(new AssetData("Number_Hurt_a", "bossNum")));
				else if (i == 1)
					bossBloodVec[i] = new Bitmap(RESManager.getBitmapData(new AssetData("Number_Hurt_b", "bossNum")));
				else
					bossBloodVec[i] = new Bitmap(RESManager.getBitmapData(new AssetData("Number_Hurt_" + (i - 2).toString(), "bossNum")));
			}
		}

		/**
		 * 清空跳血资源
		 */
		public function clearnLoaderBloodNum() : void {
			while (bossBloodVec.length != 0) {
				bossBloodVec.splice(0, 1);
			}
		}
	}
}
class proxy {
}

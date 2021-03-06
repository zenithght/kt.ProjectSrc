package game.module.notification
{
	import com.utils.StringUtils;
	import com.utils.TimeUtil;
	import game.core.item.Item;
	import game.core.item.ItemManager;
	import game.manager.VersionManager;
	import game.net.data.StoC.SCListRewardNotification.RewardItem;


	/**
	 * @author yangyiqiang
	 */
	public class VoReward
	{
		// 奖励id, 取最近的发放时间
		// public var uuid : uint;
		// 奖励类型 (如果带有0x40则表示已自动领取，不可再领取)
		// public var type : int;
		// 可选参数
		// public var params : Vector.<uint>=new Vector.<uint>();
		// 物品列表  (bind ? 0x80000000 : 0) + (id << 16) + count;
		// public var items : Vector.<uint>=new Vector.<uint>();
		private var items : Vector.<Item>=new Vector.<Item>();

		private var vo : VoICOButton;

		private var _value : RewardItem;

		public function VoReward(value : RewardItem)
		{
			_value = value;
			for each (var uuid:int in _value.items)
			createItem(uuid);
			items.sort(sortOn);
		}

		public function getId() : int
		{
			return _value.id;
		}

		public function getName() : String
		{
			initVo();
			if (!vo) return "";
			return vo.name;
		}

		private var _date : Date = new Date();

		public function getTimerString() : String
		{
			_date.time = _value.id * 1000;
			return TimeUtil.getTime(_date, false);
		}

		public function getTips() : String
		{
			initVo();
			if (!vo) return"";
			var tips : String = vo.getOldTips();
			var max:int=_value.param.length;
			for(var i:int=0;i<max;i++){
				tips = tips.replace(new RegExp("xx1" + String(i+1), "g"), _value.param[i]);
			}
			max  = items.length;
			var item : Item;
			for (i = 0;i < max;i++)
			{
				item = items[i];
				if (i == 0) tips += "：" + item.htmlName  + StringUtils.addColorById(String("×"+item.nums), item.color);
				else
					tips += "，" + item.htmlName + "×" + StringUtils.addColorById(String(item.nums), 2);
			}
			return tips;
		}

		public function getIcoUrl() : String
		{
			initVo();
			return VersionManager.instance.getUrl("assets/ico/daily/daily" + vo.dailyId + ".png");
		}

		private function initVo() : void
		{
			if (!vo)
				vo = ICOMenuManager.getInstance().getIcoVo(_value.type);
		}

		private function createItem(value : uint) : void
		{
			var bind : Boolean = value & 0x80000000 == 0 ? false : true;
			var id : uint = (value & 0x7fff0000) >> 16;
			var num : uint = value & 0xffff;
			var item : Item = ItemManager.instance.newItem(id, bind);
			item.nums = num;
			items.push(item);
		}

		private function sortOn(a : Item, b : Item) : int
		{
			return b.color - a.color;
		}
	}
}

package game.module.mapConvoy.ui
{
    import com.commUI.SwfEmbedFont;
    import com.commUI.alert.Alert;
    import com.commUI.button.KTButtonData;
    import com.commUI.icon.ItemIcon;
    import com.commUI.tooltip.ToolTip;
    import com.commUI.tooltip.ToolTipManager;
    import com.utils.ColorUtils;
    import com.utils.TimeUtil;
    import com.utils.UICreateUtils;
    import com.utils.UIUtil;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import framerate.SecondsTimer;
    import game.core.item.Item;
    import game.core.item.ItemManager;
    import game.core.user.StateManager;
    import game.core.user.UserData;
    import game.definition.UI;
    import game.manager.ViewManager;
    import game.module.mapConvoy.ConvoyConfig;
    import game.module.mapConvoy.ConvoyProto;
    import gameui.controls.GButton;
    import gameui.controls.GLabel;
    import gameui.controls.GToolTip;
    import gameui.core.GComponent;
    import gameui.core.GComponentData;
    import gameui.data.GToolTipData;
    import gameui.manager.UIManager;
    import net.AssetData;






    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-3-14 ����7:13:02
     */
    public class ConvoyInfoBox2 extends GComponent
    {
        public function ConvoyInfoBox2(singleton : Singleton)
        {
            singleton;
            _base = new GComponentData();
            _base.parent = ViewManager.instance.uiContainer;
            _base.width = 180;
            _base.height = 26;
            super(_base);
            initViews();
        }

        /** 单例对像 */
        private static var _instance : ConvoyInfoBox2;

        /** 获取单例对像 */
        static public function get instance() : ConvoyInfoBox2
        {
            if (_instance == null)
            {
                _instance = new ConvoyInfoBox2(new Singleton());
            }
            return _instance;
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        public var convoyProto : ConvoyProto = ConvoyProto.instance;
        public var itemIcon : ItemIcon;
        public var convoyIcon : Sprite;
        public var convoyIconCircle : MovieClip;
        /** 加速按钮 */
        public var fastForwardButton : GButton;
        /** 立即完成按钮 */
        public var immediatelyButton : GButton;
        /** 退出按钮 */
        public var quitButton : GButton;
        /** 剩余时间 */
        public var timerLabel : GLabel;
        public var getItemIconContentCall : Function;
        public var isShowIconCircle : Boolean = false;

        private function getItemIconContent() : String
        {
            if (getItemIconContentCall != null) return getItemIconContentCall.apply();
            return "未知";
        }

        public function updateItemIconTipContent() : void
        {
            ToolTipManager.instance.refreshToolTip(itemIcon);
        }

        private function initViews() : void
        {
            convoyIcon = SwfEmbedFont.getUI("convoyIcon");
            convoyIcon.mouseChildren = false;
            convoyIcon.mouseEnabled = true;
            convoyIcon.x = (_base.width - convoyIcon.width) >> 1;
            convoyIcon.y = -convoyIcon.height + 27;
            addChild(convoyIcon);
            // 背景
            var sprite : Sprite = UIManager.getUI(new AssetData(UI.BACKGROUND_ROUND));
            sprite.width = _base.width;
            sprite.height = _base.height;
            sprite.x = 0;
            sprite.y = 0;
            addChild(sprite);
            // 香炉物品图
            // itemIcon = UICreateUtils.createItemIcon({showBg:true, showBorder:true, showToolTip:false});
            // var item : Item = ItemManager.instance.getPileItem(ConvoyConfig.xiangLuGoodsDic[ConvoyConfig.XIANG_LU_4]);
            // itemIcon.source = item;
            // itemIcon.x = 5;
            // itemIcon.y = 5;
            // addChild(itemIcon);
            ToolTipManager.instance.registerToolTip(convoyIcon, ToolTip, getItemIconContent);

            // var label : GLabel;
            // label = UICreateUtils.createGLabel({width:75, height:20, text:"剩余时间：", x:70, y:25});
            // addChild(label);

            // 剩余时间：
            sprite = SwfEmbedFont.getUI("leftTimeLabel");
            sprite.x = 5;
            sprite.y = (_base.height - sprite.height) >> 1;
            sprite.y += 1;
            addChild(sprite);
            var label : GLabel;
            var vY : int = (_base.height - 20) >> 1;
            label = UICreateUtils.createGLabel({width:90, height:20, text:"32:15", textColor:0xFFCC00, x:56, y:vY});
            addChild(label);
            timerLabel = label;

            // 加速按钮
            // var buttonData:GButtonData = new GButtonData();
            // buttonData.x = 170;
            // buttonData.y = 23;
            // buttonData.width = 25;
            // buttonData.height = 22;
            // buttonData.toolTipData = new GToolTipData();
            // buttonData.toolTipData.labelData.text = "花费25元宝传送至下个雕像";
            // var button : GButton = new GButton(buttonData);
            vY = (_base.height - 26) >> 1;
            vY += 2;
            var button : GButton = UICreateUtils.createGButton("", 25, 22, 96, vY, KTButtonData.SMALL_BUTTON);
            button.addEventListener(MouseEvent.CLICK, fastForwardButtonOnClick);
            ToolTipManager.instance.registerToolTip(button, ToolTip, "花费<font color='"+ColorUtils.HIGHLIGHT_DARK+"'>25元宝</font>加速至下个雕像");
            addChild(button);
            fastForwardButton = button;

            var buttonIcon : Sprite = UIManager.getUI(new AssetData(UI.ICON_FAST_FORWARD));
            buttonIcon.x = (button.width - buttonIcon.width) / 2;
            buttonIcon.y = (button.height - buttonIcon.height) / 2;
            button.addChild(buttonIcon);

            // 立即完成按钮
            button = UICreateUtils.createGButton("", 25, 22, 124, vY, KTButtonData.SMALL_BUTTON);
            button.toolTip = new GToolTip(new GToolTipData());
            button.addEventListener(MouseEvent.CLICK, immediatelyButtonOnClick);
            ToolTipManager.instance.registerToolTip(button, ToolTip, getImmediatelyButtonTipContent);
            addChild(button);
            immediatelyButton = button;

            buttonIcon = UIManager.getUI(new AssetData(UI.ICON_IMMEDIATELY_FORWARD));
            buttonIcon.x = (button.width - buttonIcon.width) / 2;
            buttonIcon.y = (button.height - buttonIcon.height) / 2;
            button.addChild(buttonIcon);

            // 退出按钮
            button = UICreateUtils.createGButton("", 25, 22, 152, vY, KTButtonData.SMALL_BUTTON);
            button.toolTip = new GToolTip(new GToolTipData());
            button.addEventListener(MouseEvent.CLICK, quitButtonOnClick);
            ToolTipManager.instance.registerToolTip(button, ToolTip, "退出仙龟拜佛");
            addChild(button);
            quitButton = button;

            buttonIcon = UIManager.getUI(new AssetData(UI.ICON_CLOSE_FORWARD));
            buttonIcon.x = (button.width - buttonIcon.width) / 2;
            buttonIcon.y = (button.height - buttonIcon.height) / 2;
            button.addChild(buttonIcon);
        }

        public function quitButtonOnClick(event : MouseEvent = null) : void
        {
            quitButtonOnClickAlert = StateManager.instance.checkMsg(89, [], quitButtonOnClickAlertCall);
        }
		
		private var quitButtonOnClickAlert:Alert;
        private function quitButtonOnClickAlertCall(eventType : String) : Boolean
        {
            switch(eventType)
            {
                case Alert.OK_EVENT:
                    convoyProto.cs_stopConvoy();
                    break;
            }
            return true;
        }

        private function getImmediatelyButtonTipContent() : String
        {
            return "花费<font color='"+ColorUtils.HIGHLIGHT_DARK+"'>" + immediatelyGold + "元宝</font>立即完成护送";
        }

        public var immediatelyGold : int = 100;
        public var fastForwardGold : int = 25;

        private function immediatelyButtonOnClick(event : MouseEvent) : void
        {
            immediatelyAlert = StateManager.instance.checkMsg(91, [immediatelyGold], immediatelyAlertCall);
        }

		private var immediatelyAlert:Alert;
        private function immediatelyAlertCall(eventType : String) : Boolean
        {
            switch(eventType)
            {
                case Alert.OK_EVENT:
                    if (UserData.instance.gold < immediatelyGold)
                    {
                        StateManager.instance.checkMsg(4);
                        return false;
                    }
                    convoyProto.cs_instantConvoy(false);
                    fastForwardButton.enabled = false;
                    immediatelyButton.enabled = false;
                    quitButton.enabled = false;
                    break;
            }
            return true;
        }

        private function fastForwardButtonOnClick(event : MouseEvent) : void
        {
            StateManager.instance.checkMsg(88, [25], fastForwardAlertCall);
        }

        private function fastForwardAlertCall(eventType : String) : Boolean
        {
            switch(eventType)
            {
                case Alert.OK_EVENT:
                    if (UserData.instance.gold < 25)
                    {
                        StateManager.instance.checkMsg(4);
                        return false;
                    }
                    convoyProto.cs_instantConvoy(true);
                    fastForwardButton.enabled = false;
                    immediatelyButton.enabled = false;
                    quitButton.enabled = false;
                    break;
            }
            return true;
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        /** 是否加速中 */
        public function set fastForwarding(value : Boolean) : void
        {
            fastForwardButton.enabled = !value;
            immediatelyButton.enabled = !value;
            quitButton.enabled = !value;
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        public function set quality(value : int) : void
        {
//            var item : Item = ItemManager.instance.getPileItem(ConvoyConfig.xiangLuGoodsDic[value]);
//            itemIcon.source = item;
        }

        private var _time : int = 0;
        private var timerRuning : Boolean = false;
        public var timeCompleteCall : Function;

        public function get time() : int
        {
            return _time;
        }

        public function set time(value : int) : void
        {
            _time = value;
            timerLabel.text = TimeUtil.toMMSS(value);
            if (_time > 0 && timerRuning == false)
            {
                timerRuning = true;
                SecondsTimer.addFunction(secondsTimer);
            }
            else if (_time <= 0)
            {
                timerOnComplete();
            }
        }

        private function secondsTimer() : void
        {
            time -= 1;
        }

        public function stopTimer() : void
        {
            if (SecondsTimer) SecondsTimer.removeFunction(secondsTimer);
            timerRuning = false;
            // hide();
        }

        private function timerOnComplete() : void
        {
            if (timeCompleteCall != null) timeCompleteCall.apply(null, []);
            stopTimer();
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        override public function show() : void
        {
            if (isShowIconCircle)
            {
                if (convoyIconCircle == null)
                {
                    convoyIconCircle = UIManager.getUI(new AssetData(UI.FIRE_CIRCLE)) as MovieClip;
                    convoyIconCircle.x = -4;
                }
                convoyIconCircle.gotoAndPlay(1);
                convoyIcon.addChild(convoyIconCircle);
            }
            else if (convoyIconCircle && convoyIconCircle.parent)
            {
                convoyIconCircle.gotoAndStop(1);
                convoyIconCircle.parent.removeChild(convoyIconCircle);
            }
            UIUtil.alignStageHCenter(this);
            immediatelyGold = 100;
            y = 103;
            super.show();
            stage.addEventListener(Event.RESIZE, onStageResize);
        }

        override public function hide() : void
        {
            if (convoyIconCircle)
            {
                convoyIconCircle.gotoAndStop(1);
                if (convoyIconCircle.parent) convoyIconCircle.parent.removeChild(convoyIconCircle);
            }
			if(quitButtonOnClickAlert) quitButtonOnClickAlert.close();
			if(immediatelyAlert) immediatelyAlert.close();
            immediatelyGold = 100;
            stopTimer();
            stage.removeEventListener(Event.RESIZE, onStageResize);
            fastForwarding = false;
            super.hide();
        }

        private function onStageResize(event : Event) : void
        {
            UIUtil.alignStageHCenter(this);
            y = 103;
        }

        override public function get stage() : Stage
        {
            return UIUtil.stage;
        }
    }
}
class Singleton
{
}
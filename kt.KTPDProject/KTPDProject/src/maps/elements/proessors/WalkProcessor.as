package maps.elements.proessors
{
	import maps.auxiliarys.MapPoint;
	import maps.auxiliarys.MapPointPool;
	import maps.elements.Path;

	// ============================
	// @author ZengFeng (zengfeng75[AT]163.com) 2012-5-30
	// ============================
	public class WalkProcessor
	{
		private var callUpdatePosition : Function;
		private var callStart : Function;
		private var callTurn : Function;
		private var callEnd : Function;
		private var path : Vector.<MapPoint>;
		private var moveProcessor : AbstractMoveProcessor;
		private var position : MapPoint;
		private var tempPoint : MapPoint;
		private var moveing : Boolean;
		private static var mapPointPool : MapPointPool = MapPointPool.instance;

		function WalkProcessor() : void
		{
			path = new Vector.<MapPoint>();
			position = new MapPoint();
		}

		public function reset(position : MapPoint, speed : Number, callUpdatePosition : Function, callStart : Function, callTurn : Function, callEnd : Function, moveProessType : int) : void
		{
			this.position = position;
			this.callUpdatePosition = callUpdatePosition;
			this.callStart = callStart;
			this.callTurn = callTurn;
			this.callEnd = callEnd;
			if (moveProcessor) moveProcessor.destory();
			moveProcessor = MoveProessorFactory.instance.make(speed, updatePosition, segmentMoveEnd, moveProessType);
			moveing = false;
		}

		public function destory() : void
		{
			callUpdatePosition = null;
			callStart = null;
			callTurn = null;
			callEnd = null;
			position.destory();
			moveProcessor.destory();
			position = null;
			moveProcessor = null;
			clearPath();
		}

		public function pathTo(toX : int, toY : int) : void
		{
			Path.find(position.x, position.y, toX, toY, path);
			moveing = false;
			startMove();
		}

		public function setPath(path : Vector.<MapPoint>) : void
		{
			this.path = path;
			moveing = false;
			startMove();
		}

		public function addPathPoint(x : int, y : int) : void
		{
			path.push(mapPointPool.getObject(x, y));
			startMove();
		}
		
		public function removePathLastPoint():void
		{
			if(path.length > 0)
			{
				tempPoint = path.pop();
				tempPoint.destory();
			}
			else
			{
				stop();
			}
		}

		public function lineTo(toX : int, toY : int) : void
		{
			clearPath();
			moveing = true;
			callStart();
			callTurn(position.x, position.y, toX, toY);
			moveProcessor.move(position.x, position.y, toX, toY);
		}

		public function serverTo(toX : int, toY : int, hasFrom : Boolean, fromX : int, fromY : int) : void
		{
			if (hasFrom == false)
			{
				addPathPoint(toX, toY);
				return;
			}

			if (path.length == 0)
			{
				lineTo(toX, toY);
			}
			else if (path.length > 0)
			{
				tempPoint = path.pop();
				tempPoint.x = fromX;
				tempPoint.x = fromY;
				addPathPoint(toX, toY);
			}
		}

		public function stop() : void
		{
			clearPath();
			moveProcessor.stop();
		}

		public function changeSpeed(speed : Number) : void
		{
			moveProcessor.changeSpeed(speed);
		}

		protected function clearPath() : void
		{
			while (path.length > 0)
			{
				tempPoint = path.shift();
				tempPoint.destory();
			}
			tempPoint = null;
		}

		protected function startMove() : void
		{
			if (moveing || path.length <= 0) return;
			moveing = true;
			callStart();
			toNextPoint();
		}

		protected function toNextPoint() : void
		{
			if (path.length <= 0)
			{
				end();
				return;
			}
			tempPoint = path.shift();
			callTurn(position.x, position.y, tempPoint.x, tempPoint.y);
			moveProcessor.move(position.x, position.y, tempPoint.x, tempPoint.y);
			tempPoint.destory();
		}

		protected function segmentMoveEnd() : void
		{
			toNextPoint();
		}

		protected function updatePosition(x : int, y : int) : void
		{
			position.x = x;
			position.y = y;
			callUpdatePosition(x, y);
		}

		protected function end() : void
		{
			moveing = false;
			callEnd();
		}
	}
}

package game.net.data.StoC {
	/**
	 * Server to Client 协议号0xE3
	 **/
	import com.protobuf.*;
	import flash.utils.IDataInput;
	import flash.errors.IOError;
	public dynamic final class SCActivateArtifactsRes extends com.protobuf.Message {
		 /**
		  *@result   result
		  **/
		public var result:uint;

		 /**
		  *@level   level
		  **/
		public var level:uint;

		override public final function readFromSlice(input:flash.utils.IDataInput, bytesAfterSlice:uint):void {
			var result$count:uint = 0;
			var level$count:uint = 0;
			while (input.bytesAvailable > bytesAfterSlice) {
				var tag:uint = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
				switch (tag >> 3) {
				case 1:
					if (result$count != 0) {
						throw new flash.errors.IOError('Bad data format: SCActivateArtifactsRes.result cannot be set twice.');
					}
					++result$count;
					result = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
					break;
				case 2:
					if (level$count != 0) {
						throw new flash.errors.IOError('Bad data format: SCActivateArtifactsRes.level cannot be set twice.');
					}
					++level$count;
					level = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
					break;
				default:
					super.readUnknown(input, tag);
					break;
				}
			}
		}

	}
}

package game.net.data.CtoS {
	/**
	 * Client to Server  协议号0x38
	 **/
	import com.protobuf.*;
	public dynamic final class CSNpcReAction extends com.protobuf.Message {
		 /**
		  *@actionId   actionId
		  **/
		public var actionId:uint;

		
		override public final function writeToBuffer(output:com.protobuf.WritingBuffer):void {
			com.protobuf.WriteUtils.writeTag(output, com.protobuf.WireType.VARINT, 1);
			com.protobuf.WriteUtils.write$TYPE_UINT32(output, actionId);
			for (var fieldKey:* in this) {
				super.writeUnknown(output, fieldKey);
			}
		}

		
	}
}

package game.net.data.CtoS {
	/**
	 * Client to Server  协议号0xE3
	 **/
	import com.protobuf.*;
	public dynamic final class CSActivateArtifacts extends com.protobuf.Message {
		
		override public final function writeToBuffer(output:com.protobuf.WritingBuffer):void {
			for (var fieldKey:* in this) {
				super.writeUnknown(output, fieldKey);
			}
		}

		
	}
}

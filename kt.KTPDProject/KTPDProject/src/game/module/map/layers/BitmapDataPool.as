// // // // // // // // // // ///////////////////////////////////////
// BitmapDataPool.as
// Macromedia ActionScript Implementation of the Class BitmapDataPool
// Generated by Enterprise Architect
// Created on:      11-五月-2012 15:20:01
// Original author: ZengFeng
// // // // // // // // // // ///////////////////////////////////////
package game.module.map.layers
{
    import flash.display.BitmapData;

    /**
     * 固定大小的区块可以从这个池中获取
     * @author ZengFeng
     * @version 1.0
     * @updated 11-五月-2012 15:22:38
     */
    internal class BitmapDataPool
    {
        /** 单例对像 */
        private static var _instance : BitmapDataPool;

        /** 获取单例对像 */
        static public function get instance() : BitmapDataPool
        {
            if (_instance == null)
            {
                _instance = new BitmapDataPool(new Singleton());
            }
            return _instance;
        }

        public static const WIDTH : int = 256 ;
        public static const HEIGHT : int = 256 ;
        private var list : Vector.<BitmapData> = new Vector.<BitmapData>();

        function BitmapDataPool(singleton : Singleton)
        {
        }

        public function getObject() : BitmapData
        {
            if (list.length > 0)
            {
                return list.pop();
            }
            return new BitmapData(WIDTH, HEIGHT, false, Math.random() * 0xFFFFFF);
        }

        /**
         * 
         * @param bitmapData
         */
        public function destoryObject(bitmapData : BitmapData) : void
        {
            if (bitmapData == null) return;
            if (list.indexOf(bitmapData) != -1) return;
            list.push(bitmapData);
        }
    }
    // end BitmapDataPool
}
class Singleton
{
}
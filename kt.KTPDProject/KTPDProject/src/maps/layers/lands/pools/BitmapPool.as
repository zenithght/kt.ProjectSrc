// // // // // // ///////////////////////////////////////////////
// BitmapPool.as
// Macromedia ActionScript Implementation of the Class BitmapPool
// Generated by Enterprise Architect
// Created on:      11-五月-2012 15:20:01
// Original author: ZengFeng
// // // // // // ///////////////////////////////////////////////
package maps.layers.lands.pools
{
    import flash.display.Bitmap;

    /**
     * Bitmap对像池
     * @author ZengFeng
     * @version 1.0
     * @updated 11-五月-2012 15:22:38
     */
    public class BitmapPool
    {
        /** 单例对像 */
        private static var _instance : BitmapPool;

        /** 获取单例对像 */
        static public function get instance() : BitmapPool
        {
            if (_instance == null)
            {
                _instance = new BitmapPool(new Singleton());
            }
            return _instance;
        }

        private var list : Vector.<Bitmap> = new Vector.<Bitmap>();

        function BitmapPool(singleton : Singleton)
        {
        }

        public function getObject() : Bitmap
        {
            if (list.length > 0)
            {
                return list.pop();
            }
            return new Bitmap();
        }

        /**
         * 
         * @param bitmap
         */
        public function destoryObject(bitmap : Bitmap) : void
        {
            if (bitmap == null) return;
            if (list.indexOf(bitmap) != -1) return;
            bitmap.bitmapData = null;
            list.push(bitmap);
        }
    }
    // end BitmapPool
}
class Singleton
{
}
////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2011 CodeCatalyst, LLC - http://www.codecatalyst.com/
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.	
////////////////////////////////////////////////////////////////////////////////

package com.codecatalyst.promise
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	/**
	 * Deferred.
	 * 
	 * A chainable utility object that can register multiple callbacks into callback queues, invoke callback queues,
	 * and relay the success, failure and progress _state of any synchronous or asynchronous operation.
	 * 
	 * @see com.codecatalyst.util.promise.Promise
	 * 
	 * Inspired by jQuery's Deferred implementation.
	 * 
 	 * @author John Yanarella
	 */
	public class Deferred extends EventDispatcher
	{
		// ========================================
		// Protected constants
		// ========================================
		
		/**
		 * Internal _state change Event type.
		 */
		internal static const STATE_CHANGED:String = "stateChanged";

		// ========================================
		// Public constants
		// ========================================
		
		/**
		 * State for a Deferred that has not yet been resolved, rejected or cancelled.
		 */
		public static const PENDING_STATE:String = "pending";

		/**
		 * State for a Deferred that has been resolved.
		 */
		public static const RESOLVED_STATE:String = "resolved";

		/**
		 * State for a Deferred that has been rejected.
		 */
		public static const REJECTED_STATE:String = "rejected";
		
		/**
		 * State for a Deferred that has been cancelled.
		 */
		public static const CANCELLED_STATE:String = "cancelled";
		
		// ========================================
		// Public properties
		// ========================================
		
		/**
		 * Promise.
		 */
		public function get promise():Promise
		{
			return _promise;
		}
		
		[Bindable( "stateChanged" )]
		/**
		 * Exposes read-only value of current state
		 */
		public function get state():String
		{
			return _state;
		}
		

		[Bindable( "stateChanged" )]
		/**
		 * Indicates this Deferred has not yet been resolved, rejected or cancelled.
		 */
		public function get pending():Boolean
		{
			return ( _state == PENDING_STATE );
		}
		

		[Bindable( "stateChanged" )]
		/**
		 * Indicates this Deferred has been resolved.
		 * Alias function; used to match jQuery API
		 */
		public function get resolved():Boolean {
			return ( _state == RESOLVED_STATE );
		}
		
		[Bindable( "stateChanged" )]
		/**
		 * Indicates this Deferred has been rejected.
		 * Alias function; used to match jQuery API
		 */
		public function get rejected():Boolean {
			return ( _state == REJECTED_STATE );
		}
		
		[Bindable( "stateChanged" )]
		/**
		 * Indicates this Deferred has been cancelled
		 * Alias function; used to match jQuery API
		 */
		public function get cancelled():Boolean {
			return ( _state == CANCELLED_STATE );
		}
		
		
		[Bindable( "stateChanged" )]
		/**
		 * Progress supplied when this Deferred was updated.
		 */
		public function get status():*
		{
			return _progress;
		}
		
		[Bindable( "stateChanged" )]
		/**
		 * Result supplied when this Deferred was resolved.
		 */
		public function get result():*
		{
			return _result;
		}
		
		[Bindable( "stateChanged" )]
		/**
		 * Error supplied when this Deferred was rejected.
		 */
		public function get error():*
		{
			return _error;
		}
		
		[Bindable( "stateChanged" )]
		/**
		 * Reason supplied when this Deferred was cancelled.
		 */
		public function get reason():*
		{
			return _reason;
		}
		
		// ========================================
		// Protected properties
		// ========================================
		
		/**
		 * Backing variable for <code>promise</code> property.
		 */
		protected var _promise:Promise = null;
		
		/**
		 * Backing variable for <code>progress</code.
		 */
		protected var _progress:* = null;
		
		/**
		 * Backing variable for <code>result</code.
		 */
		protected var _result:* = null;
		
		/**
		 * Backing variable for <code>error</code.
		 */
		protected var _error:* = null;
		
		/**
		 * Backing variable for <code>reason</code.
		 */
		protected var _reason:* = null;
		
		/**
		 * Deferred _state.
		 * 
		 * @see #STATE_PENDING
		 * @see #STATE_RESOLVED
		 * @see #STATE_REJECTED
		 * @see #STATE_CANCELLED
		 */
		protected var _state:String = Deferred.PENDING_STATE;
		
		/**
		 * Callbacks to be called when this Deferred is updated.
		 */
		protected var progressCallbacks:Array = [];
		
		/**
		 * Callbacks to be called when this Deferred is resolved.
		 */
		protected var resultCallbacks:Array = [];
		
		/**
		 * Callbacks to be called when this Deferred is rejected.
		 */
		protected var errorCallbacks:Array = [];
		
		/**
		 * Callbacks to be called when this Deferred is cancelled.
		 */
		protected var cancelCallbacks:Array = [];
		
		/**
		 * Callbacks to be called when this Deferred is resolved or rejected.
		 */
		protected var alwaysCallbacks:Array = [];
		
		// ========================================
		// Constructor
		// ========================================
		
		/**
		 * Constructor.
		 */
		public function Deferred(callback:Function=null)
		{
			super();
			
			_promise = new Promise( this );
			
			if ( callback ) 
			{
				callback.apply( this, callback.length ? [this] : [ ] );
			}
		}
		
		// ========================================
		// Public methods
		// ========================================
		
		/**
		 * Alias to support jQuery API
		 */
		public function done( callback:Function=null ) :Deferred {
			return onResult(callback);
		}
		
		/**
		 * Alias to support jQuery API
		 */
		public function fail( callback:Function=null ) :Deferred {
			return onError(callback);
		}
		
		/**
		 * Alias to support jQuery API
		 */
		public function progress( callback:Function=null ) :Deferred {
			return onProgress(callback);
		}
		

		
		/**
		 * Register callbacks to be called when this Deferred is resolved, rejected, cancelled and updated.
		 */
		public function then( resultCallback:Function=null, errorCallback:Function = null, progressCallback:Function = null, cancelCallback:Function = null ):Deferred
		{
			onResult( resultCallback );
			onError( errorCallback );
			onProgress( progressCallback );
			onCancel( cancelCallback );
			
			return this;
		}
		
		/**
		 * Registers a callback to be called when this Deferred is either resolved, rejected or cancelled.
		 */
		public function always( alwaysCallback:Function=null):Deferred
		{
			if ( alwaysCallback != null )
			{
				if ( pending )
				{
					alwaysCallbacks.push( alwaysCallback );
				}
				else if ( resolved)
				{
					notifyCallbacks( [ alwaysCallback ], result );
				}
				else if ( rejected )
				{
					notifyCallbacks( [ alwaysCallback ], error );
				}
				else if ( cancelled )
				{
					notifyCallbacks( [ alwaysCallback ], reason );
				}
			}
				
			return this;
		}
		
		/**
		 * Utility method to filter and/or chain Deferreds.
		 */
		public function pipe( resultCallback:Function=null, errorCallback:Function = null, progressCallback:Function=null ):Promise
		{
			var deferred:Deferred = new Deferred();
			
			then(
				function ( result:* ):void
				{
					if ( resultCallback != null )
					{
						var returnValue:* = resultCallback( result );
						if ( returnValue is Deferred )
						{
							returnValue.promise.then( deferred.resolve, deferred.reject, deferred.update, deferred.cancel );
						}
						else if ( returnValue is Promise )
						{
							returnValue.then( deferred.resolve, deferred.reject, deferred.update, deferred.cancel );
						}
						else
						{
							deferred.resolve( returnValue );
						}
					}
					else
					{
						deferred.resolve( result );
					}
				},
				function ( error:* ):void
				{
					if ( errorCallback != null )
					{
						var returnValue:* = errorCallback( error );
						if ( returnValue is Deferred )
						{
							returnValue.promise.then( deferred.resolve, deferred.reject, deferred.update, deferred.cancel );
						}
						else if ( returnValue is Promise )
						{
							returnValue.then( deferred.resolve, deferred.reject, deferred.update, deferred.cancel );
						}
						else
						{
							deferred.reject( returnValue );
						}
					}
					else
					{
						deferred.reject( error );
					}
				},
				function ( update:* ):void
				{
					if ( progressCallback != null )
					{
						var returnValue:* = progressCallback( update );
						if ( returnValue is Deferred )
						{
							returnValue.promise.then( deferred.resolve, deferred.reject, deferred.update, deferred.cancel );
						}
						else if ( returnValue is Promise )
						{
							returnValue.then( deferred.resolve, deferred.reject, deferred.update, deferred.cancel );
						}
						else
						{
							deferred.update( returnValue );
						}
					}
					else
					{
						deferred.update( update );
					}
				},
				function ( reason:* ):void
				{
					deferred.cancel( reason );
				}
			);
			
			return deferred.promise;
		}
		
		/**
		 * Registers a callback to be called when this Deferred is updated.
		 */
		public function onProgress( progressCallback:Function ):Deferred
		{
			if ( progressCallback != null )
			{
				if ( pending )
				{
					progressCallbacks.push( progressCallback );
					
					if ( status != null )
						notifyCallbacks( [ progressCallback ], status );
				}
			}
			
			return this;
		}
		
		
		/**
		 * Registers a callback to be called when this Deferred is resolved.
		 */
		public function onResult( callback:Function ):Deferred
		{
			if ( callback != null )
			{
				if ( pending && !contains(resultCallbacks,callback))
				{
					resultCallbacks.push( callback );
				}
				else if ( resolved )
				{
					notifyCallbacks( [ callback ], result );
				}
			}
			
			return this;
		}
		
		/**
		 * Registers a callback to be called when this Deferred is rejected.
		 */
		public function onError( callback:Function ):Deferred
		{
			if ( callback != null )
			{
				if ( pending  && !contains(errorCallbacks,callback))
				{
					errorCallbacks.push( callback );
				}
				else if ( rejected )
				{
					notifyCallbacks( [ callback ], error );
				}
			}
			
			return this;
		}
		
		
		/**
		 * Registers a callback to be called when this Deferred is cancelled.
		 */
		public function onCancel( cancelCallback:Function ):Deferred
		{
			if ( cancelCallback != null )
			{
				if ( pending )
				{
					cancelCallbacks.push( cancelCallback );
				}
				else if ( cancelled )
				{
					notifyCallbacks( [ cancelCallback ], reason );
				}
			}
			
			return this;
		}
		
		/**
		 * Update this Deferred and notifyCallbacks relevant callbacks.
		 */
		public function update( progress:*=null ):Deferred
		{
			if ( pending )
			{
				_progress = progress;
				
				notifyCallbacks( progressCallbacks, progress );
			}
			
			return this;
		}
		
		

		/**
		 *  Same as update(); but alias is useful to match Javascript API
		 *
		 *  @see ::update()
		 */ 
		public function notify( progress:*=null ):Deferred 
		{
			return update( progress );
		}
		
		/**
		 * Resolve this Deferred and notifyCallbacks relevant callbacks.
		 */
		public function resolve( results:*=null ):Deferred
		{
			if ( pending )
			{
				_result = results;
				
				setState( Deferred.RESOLVED_STATE );
				
				notifyCallbacks( resultCallbacks.concat( alwaysCallbacks ), results );
				releaseCallbacks();
			}
			
			return this;
		}
		
		/**
		 * Reject this Deferred and notifyCallbacks relevant callbacks.
		 */
		public function reject( error:*=null ):Deferred
		{
			if ( pending )
			{
				_error = error;
				
				setState( Deferred.REJECTED_STATE );
				
				notifyCallbacks( errorCallbacks.concat( alwaysCallbacks ), error );
				releaseCallbacks();
			}
			
			return this;
		}
		
		/**
		 * Cancel this Deferred and notifyCallbacks relevant callbacks.
		 */
		public function cancel( reason:*=null ):Deferred
		{
			if ( pending )
			{
				_reason = reason;
				
				setState( Deferred.CANCELLED_STATE );
				
				notifyCallbacks( cancelCallbacks.concat( alwaysCallbacks ), reason );
				releaseCallbacks();
			}
			
			return this;
		}
		
		// ========================================
		// Protected methods
		// ========================================
		
		/**
		 * Set the _state for this Deferred.
		 * 
		 * @see #pending
		 * @see #resolved
		 * @see #rejected
		 * @see #cancelled
		 */
		protected function setState( value:String ):void
		{
			if ( value != _state )
			{
				_state = value;				
				dispatchEvent( new Event( STATE_CHANGED ) );
			}
		}
		
		/**
		 * Notify the specified callbacks, optionally passing the a reference to this Deferred and the specified value.
		 */
		protected function notifyCallbacks( callbacks:Array, value:* ):void
		{
			for each ( var callback:Function in callbacks )
			{
				switch ( callback.length )
				{
					case 2:
						callback( promise, value );
						break;
					
					case 1:
						callback.call(this, value );
						break;
					
					default:
						callback.call(this);
						break;
				}
			}
		}
		
		/**
		 * Release references to all callbacks registered with this Deferred.
		 */
		protected function releaseCallbacks():void
		{
			resultCallbacks   = [];
			errorCallbacks    = [];
			progressCallbacks = [];
			cancelCallbacks   = [];
			alwaysCallbacks   = [];
		}
		
		/**
		 * Utility methods to simulate Array.contains() 
		 */
		private function contains(list:Array,item:*):Boolean {
			return (list.indexOf(item) > -1)
		}
	}
}
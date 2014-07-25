package overgen.android
{
	import com.freshplanet.ane.AirFacebook.Facebook;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.StatusEvent;
	
	import fl.controls.Button;
	import fl.controls.TextArea;
	
	public class OverGenANE extends Sprite
	{
		private static const APP_ID:String = "259182507563533";
		private static const READ_PERMISSIONS:Array = ["read_stream", "read_friendlists"];
		private static const POST_PERMISSIONS:Array = ["publish_stream"];
		
		
		private var _fb:Facebook;
		private var loginBTN:Button;
		private var infoBTN:Button;
		private var messageBTN:Button;
		private var texteInfo:TextArea;
		private var texteMessage:TextArea;
		
		public function OverGenANE()
		{
			super();			
			this.addEventListener(Event.ADDED_TO_STAGE, init);			
		}
		
		protected function init($evt:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			
			drawScreen();
			
			showInfo('facebook.isSupported:', Facebook.isSupported);
			
			//facebook app is installed
			if(Facebook.isSupported)
			{
				_fb = Facebook.getInstance();
				_fb.addEventListener(StatusEvent.STATUS, handler_status);
				_fb.init(APP_ID);
				
				showInfo("isSeesionOpen:", _fb.isSessionOpen);
				if(_fb.isSessionOpen)
				{
					loginSuccess();
					_fb.dialog("oauth", null, handler_dialog, true);
				}
				else
				{
					loginBTN.addEventListener(MouseEvent.CLICK, handler_loginBTNclick);
				}
			}
		}
		
		private function drawScreen():void 
		{					
			loginBTN = new Button();
			loginBTN.label = "Login";
			loginBTN.x = stage.stageWidth/2 - loginBTN.width-50;
			loginBTN.y = 30;
			
			addChild(loginBTN);
			
			infoBTN = new Button();
			infoBTN.label = "Get Info";
			infoBTN.x = stage.stageWidth/2 +50;
			infoBTN.y = 30;
			infoBTN.enabled = false;
			addChild(infoBTN);	
			
			texteMessage= new TextArea();
			texteMessage.width= stage.stageWidth;
			texteMessage.height= 35;
			texteMessage.x = 0;
			texteMessage.y = 70;			
			texteMessage.maxChars=80;
			texteMessage.enabled=false;
			addChild(texteMessage);
			
			messageBTN= new Button();
			messageBTN.label= "Publish";
			messageBTN.x=stage.stageWidth - messageBTN.width;
			messageBTN.y= texteMessage.y+ texteMessage.height+8;
			messageBTN.enabled=false;			
			addChild(messageBTN);
			
			
			texteInfo = new TextArea();
			texteInfo.x = 0;
			texteInfo.y = 145;
			texteInfo.width = stage.stageWidth;
			texteInfo.height = stage.stageHeight - 160;
			texteInfo.editable = false;
			addChild(texteInfo);
		}
		///////////login with read permissions
		protected function handler_loginBTNclick($evt:MouseEvent):void
		{
			if(!_fb.isSessionOpen)
			{
				_fb.openSessionWithReadPermissions(READ_PERMISSIONS, handler_openSessionWithPermissions);
			}
			else
			{
				showInfo('isSessionOpen!');
			}
		}
		
		/////////handle session
		private function handler_openSessionWithPermissions($success:Boolean, $userCancelled:Boolean, $error:String = null):void
		{
			if($success)
			{
				loginSuccess();
			}
			showInfo("success:", $success, ",userCancelled:", $userCancelled, ",error:", $error);
			
			//extend post permissions
			_fb.reauthorizeSessionWithPublishPermissions(POST_PERMISSIONS);
		}
		
		////////login succes
		private function loginSuccess():void
		{
			infoBTN.enabled = true;
			infoBTN.addEventListener(MouseEvent.CLICK, handler_infoBTNclick);
			messageBTN.enabled=true;			
			messageBTN.addEventListener(MouseEvent.CLICK, handler_messageBTNclick);
			texteMessage.enabled=true;
			loginBTN.removeEventListener(MouseEvent.CLICK, handler_loginBTNclick);
			loginBTN.addEventListener(MouseEvent.CLICK, handler_logoutBTNclick);
			loginBTN.label = "Logout";
		}
		
		///////////get info event
		protected function handler_infoBTNclick($evt:MouseEvent):void
		{
			texteInfo.text="";
			//_fb.requestWithGraphPath("/me/friends", null, "GET", handler_requesetWithGraphPath);
			var params:Object = { 
				message: "test",
				link: "http://www.google.com",
				caption: "overgen"
				
			}
			_fb.dialog("feed", params, handler_feed_dialog, true);
		}
		
		private function handler_feed_dialog():void
		{
			// TODO Auto Generated method stub
			
		}
		
		///////////publish event
		protected function handler_messageBTNclick($evt:MouseEvent):void
		{
			if (texteMessage.text != "")
			{
				var params:Object = { message: texteMessage.text }
				_fb.requestWithGraphPath("/me/feed", params, "POST",handler_requesetWithGraphPath);
			}
			else {
				texteMessage.text = "Message can't be empty";
			}
			
		}
		
		////////logout event
		private function logoutSuccess():void
		{
			loginBTN.removeEventListener(MouseEvent.CLICK, handler_logoutBTNclick);
			loginBTN.addEventListener(MouseEvent.CLICK, handler_loginBTNclick);
			loginBTN.label = "Login";
			infoBTN.enabled = false;
			messageBTN.enabled=false;
			texteInfo.text="";
			texteMessage.text="";
			texteMessage.enabled=false;
		}						
		
		///////logout handler and token cleared
		protected function handler_logoutBTNclick($evt:MouseEvent):void
		{
			_fb.closeSessionAndClearTokenInformation();
			logoutSuccess();
		}
		
		protected function handler_status($evt:StatusEvent):void
		{
			showInfo("statusEvent,type:", $evt.type,",code:", $evt.code,",level:", $evt.level);
		}
		
		private function handler_dialog($data:Object):void
		{
			showInfo('handler_dialog:', JSON.stringify($data));
		}
		
		private function handler_requesetWithGraphPath($data:Object):void
		{
			showInfo("handler_requesetWithGraphPath:", JSON.stringify($data));  
		}
		
		private function showInfo(...$args):void
		{
			var _msg:String = "";
			for (var i:int = 0; i < $args.length; i++) 
			{
				_msg += $args[i] + " ";
			}
			_msg += "\n";
			texteInfo.appendText(_msg);
		}
	}
}
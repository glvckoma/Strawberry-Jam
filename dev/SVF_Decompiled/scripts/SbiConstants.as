package
{
   public class SbiConstants
   {
      public static const ACCOUNT_TYPE_ARCHIVED:int = -2;
      
      public static const ACCOUNT_TYPE_NEW:int = -1;
      
      public static const ACCOUNT_TYPE_NONE:int = 0;
      
      public static const NON_MEMBER:int = 1;
      
      public static const PREMIUM_MEMBER:int = 2;
      
      public static const BETA_MEMBER:int = 3;
      
      public static const INTERNAL:int = 4;
      
      public static const COMMUNITY:int = 5;
      
      public static const INTERACTION_TYPE_BUDDY:int = 0;
      
      public static const INTERACTION_TYPE_TRADE:int = 1;
      
      public static const INTERACTION_TYPE_GIFT:int = 2;
      
      public static const INTERACTION_TYPE_CHAT:int = 3;
      
      public static const INTERACTION_TYPE_JAG:int = 4;
      
      public static const INTERACTION_TYPE_MULTIPLAYER:int = 5;
      
      public static const INTERACTION_TYPE_PVP:int = 6;
      
      public static const INTERACTION_TYPE_QUEST:int = 7;
      
      public static const ENVIRO_LAND:int = 0;
      
      public static const ENVIRO_OCEAN:int = 1;
      
      public static const ENVIRO_AIR:int = 2;
      
      public static const ENVIRO_LAND_AND_OCEAN:int = 3;
      
      public static const ROOMTYPE_WORLD:int = 0;
      
      public static const ROOMTYPE_GAME:int = 1;
      
      public static const ROOMTYPE_DEN:int = 2;
      
      public static const ROOMTYPE_LOBBY:int = 3;
      
      public static const ROOMTYPE_FFM:int = 4;
      
      public static const ROOMTYPE_PARTY:int = 5;
      
      public static const ROOMTYPE_WORLDGAME:int = 6;
      
      public static const ROOMTYPE_QUEST:int = 7;
      
      public static const ROOMTYPE_QUEST_STAGING:int = 8;
      
      public static const CHAT_TYPE_TYPED:int = 0;
      
      public static const CHAT_TYPE_SAFE:int = 1;
      
      public static const CHAT_TYPE_EMOTE:int = 2;
      
      public static const CHAT_TYPE_ACTION:int = 3;
      
      public static const CHAT_TYPE_ATTACHMENT:int = 4;
      
      public static const CHAT_TYPE_PERM_EMOTE:int = 5;
      
      public static const CHAT_TYPE_SLIDE:int = 6;
      
      public static const CHAT_TYPE_PET_ACTION:int = 7;
      
      public static const CHAT_TYPE_BLEND_COLOR:int = 8;
      
      public static const CHAT_TYPE_LIMITED:int = 9;
      
      public static const CHAT_TYPE_ALPHA_LEVEL:int = 10;
      
      public static const CHAT_TYPE_CUST_ADVENTURE:int = 11;
      
      public static const CHAT_TYPE_CUST_PVP:int = 12;
      
      public static const CHAT_TYPE_BUBBLE:int = 0;
      
      public static const CHAT_TYPE_FREE:int = 1;
      
      public static const CHAT_TYPE_PREDICTIVE:int = 2;
      
      public static const CHAT_TYPE_RESTR_BUBBLE:int = 3;
      
      public static const PLAYER_WALL_LOCKED:int = 0;
      
      public static const PLAYER_WALL_BUDDIES:int = 1;
      
      public static const PLAYER_WALL_EVERYONE:int = 2;
      
      public static const PLAYER_WALL_WEB_DISABLED:int = 0;
      
      public static const PLAYER_WALL_WEB_ENABLED:int = 1;
      
      public static const PLAYER_WALL_TOKEN_LOCKED_FAILURE:int = -1;
      
      public static const PLAYER_WALL_TOKEN_BUDDIES_FAILURE:int = -2;
      
      public static const PLAYER_WALL_FAILURE_TOKEN:String = "token";
      
      public static const PLAYER_WALL_FAILURE_UNAVAILABLE:String = "unavailable";
      
      public static const LAYER_BASE_ID:int = 1;
      
      public static const LAYER_PATTERN_ID:int = 2;
      
      public static const LAYER_EYE_ID:int = 3;
      
      public static const GEM_CURRENCY:int = 0;
      
      public static const TICKET_CURRENCY:int = 1;
      
      public static const CRYSTAL_CURRENCY:int = 2;
      
      public static const DIAMOND_CURRENCY:int = 3;
      
      public static const STRAW_CURRENCY:int = 4;
      
      public static const BAMBOO_CURRENCY:int = 5;
      
      public static const WOOD_CURRENCY:int = 6;
      
      public static const STONE_CURRENCY:int = 7;
      
      public static const SILVER_CURRENCY:int = 8;
      
      public static const GOLD_CURRENCY:int = 9;
      
      public static const GEM_STONE_CURRENCY:int = 10;
      
      public static const ECO_CURRENCY:int = 11;
      
      public static const NUM_CURRENCY_TYPES:int = 12;
      
      public static const COMBINED_CURRENCY:int = 100;
      
      public static const TRADE_OFFER_MAX:int = 20;
      
      public static const TEXT_RESTRICTION_ENGLISH:String = "A-Za-z0-9!\'.,():?\\- ";
      
      public static const TEXT_RESTRICTION:String = "A-Za-z0-9À-ÖØ-öø-ÿ!\'.,():?¿¡\\- ";
      
      public static const PET_INVENTORY_MAX:int = 1000;
      
      public static const PET_EGG_HATCH_SINGLE_STEP_TIME:int = 86400;
      
      public static const PET_EGG_HATCH_TIME:int = 259200;
      
      public static const MAX_EMAIL_LENGTH:int = 50;
      
      public static const NORMAL_ITEM:int = 0;
      
      public static const NEW_ITEM:int = 1;
      
      public static const SALE_ITEM:int = 2;
      
      public static const CLEARANCE_ITEM:int = 3;
      
      public static const RARE_ITEM:int = 4;
      
      public static const DEFAULT_CHAT_COLOR:int = 4531987;
      
      public static const LE_SUCCESS:int = 1;
      
      public static const LE_MX_LOOKUP_FAILED:int = 0;
      
      public static const LE_DEFAULT_FAILURE:int = -1;
      
      public static const LE_PUNISHER_EMAIL_BLACKLISTED:int = -2;
      
      public static const LE_PUNISHER_500_RESPONE:int = -3;
      
      public static const LE_PUNISHER_GENERIC_FAILURE:int = -4;
      
      public static const PRIVACY_SETTING_LOCKED:int = 0;
      
      public static const PRIVACY_SETTING_BUDDIES:int = 1;
      
      public static const PRIVACY_SETTING_EVERYONE:int = 2;
      
      public static const ACCOUNT_SUBSCRIPTION_TYPE_UNKNOWN:int = 0;
      
      public static const ACCOUNT_SUBSCRIPTION_TYPE_PROMOTION:int = 11;
      
      public static const PROMOTION_TYPE_STANDARD:int = 1;
      
      public static const PROMOTION_TYPE_REFERRAL:int = 2;
      
      public static const MIN_LENGTH_USERNAME:int = 2;
      
      public static const MAX_LENGTH_USERNAME_FOR_CREATION:int = 20;
      
      public static const UV_DEF_CUSTOM_AVT_PROMO_FLAG:int = 0;
      
      public static const ITEM_TYPE_DEN_ITEM:int = 0;
      
      public static const ITEM_TYPE_PET:int = 1;
      
      public static const ITEM_TYPE_CLOTHING:int = 2;
      
      public static const MIN_ELECTRON_VERSION:String = "1.5.3";
      
      public static const CURRENCY_NAMES:Vector.<String> = Vector.<String>(["gems","tickets","orbs","diamonds","straw","bamboo","wood","stone","silver","gold","gemstone","ecoCredits"]);
      
      public static const ACHIEVEMENT_TYPE_NAMES:Array = [23527,22833,22834,22835,22836,22825,22837,22826,22838,22854,22856,22839,22840,22859,22850,22841,22857,22842,22827,22851,22843,22852,22844,22853,22828,22855,22829,22845,22858,23528,22830,22846,22847,22831,22832,22848,22849,29291];
      
      public static const USERNAME_REGEX:RegExp = /^[a-zA-z0-9À-ÏÑ-ÖØ-Üß-ïñ-öø-üÿŸ][a-z0-9ß-ïñ-öø-üÿ]+$/i;
      
      public static const EMAIL_REGEX:RegExp = new RegExp(/^[\w%+\.-]+@(?:[a-zA-Z0-9-]+[\.{1}])+[a-zA-Z]{2,}$/i);
      
      public static const TEXT_PUNCTUATION_ENGLISH:RegExp = /[.!?,]/ig;
      
      public static const TEXT_PUNCTUATION:RegExp = /[.!?,¿¡]/ig;
      
      public static const TEXT_IGNORE_FOR_CAPITALIZATION:RegExp = /[\[\]':,\-!().?\";\\/¿¡]/ig;
      
      public static const COMMON_DOMAINS:Array = ["yahoo.com","hotmail.com","gmail.com","comcast.net","sbcglobal.net","att.net","msn.com","microsoft.com","aim.com","charter.net","aol.com","cox.net","live.com","live.ca","verizon.net","xtra.co.nz","shaw.ca","bellsouth.net","roadrunner.com","hotmail.co.uk","yahoo.co.uk","optonline.net","centurylink.net","centurytel.net","mail.com","mac.com","google.com","googlemail.com","compuserve.com","myspace.com","facebook.com","youtube.com","netscape.net","emailaccount.com","earthlink.net","rocketmail.com","broadband.com","ymail.com","supermail.com","junkmail.com","mindspring.com","juno.com","prodigy.net","excite.com","frontiernet.net","frontier.com","epix.net","love.com","hellokitty.com","sky.com","pacbell.net","champmail.com","heartmail.com","dragon.com","computer.org","digis.net","yahoo.ca","hotmail.ca","googlemail.co.uk","msn.ca","msn.co.uk","microsoft.co.uk","microsoft.ca","aol.co.uk","live.co.uk","compuserve.co.uk","netscape.ca"];
      
      public function SbiConstants()
      {
         super();
      }
   }
}


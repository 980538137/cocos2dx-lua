#include "AppDelegate.h"
#include "CCLuaEngine.h"
#include "SimpleAudioEngine.h"
#include "cocos2d.h"
#include "lua_module_register.h"
#if (CC_TARGET_PLATFORM != CC_PLATFORM_LINUX)
#include "ide-support/CodeIDESupport.h"
#endif

#if (COCOS2D_DEBUG > 0) && (CC_CODE_IDE_DEBUG_SUPPORT > 0)
#include "runtime/Runtime.h"
#include "ide-support/RuntimeLuaImpl.h"
#endif
//#include "pbc-lua.c"

using namespace CocosDenshion;

USING_NS_CC;
using namespace std;

AppDelegate::AppDelegate()
{
}

AppDelegate::~AppDelegate()
{
    SimpleAudioEngine::end();
    
#if (COCOS2D_DEBUG > 0) && (CC_CODE_IDE_DEBUG_SUPPORT > 0)
    // NOTE:Please don't remove this call if you want to debug with Cocos Code IDE
    RuntimeEngine::getInstance()->end();
#endif
    
}

//if you want a different context,just modify the value of glContextAttrs
//it will takes effect on all platforms
void AppDelegate::initGLContextAttrs()
{
    //set OpenGL context attributions,now can only set six attributions:
    //red,green,blue,alpha,depth,stencil
    GLContextAttrs glContextAttrs = {8, 8, 8, 8, 24, 8};
    
    GLView::setGLContextAttrs(glContextAttrs);
}

// If you want to use packages manager to install more packages,
// don't modify or remove this function
static int register_all_packages()
{
    return 0; //flag for packages manager
}

int lua_print(lua_State * luastate)
{
    int nargs = lua_gettop(luastate);
    
    std::string t;
    for (int i=1; i <= nargs; i++)
    {
        if (lua_istable(luastate, i))
            t += "table";
        else if (lua_isnone(luastate, i))
            t += "none";
        else if (lua_isnil(luastate, i))
            t += "nil";
        else if (lua_isboolean(luastate, i))
        {
            if (lua_toboolean(luastate, i) != 0)
                t += "true";
            else
                t += "false";
        }
        else if (lua_isfunction(luastate, i))
            t += "function";
        else if (lua_islightuserdata(luastate, i))
            t += "lightuserdata";
        else if (lua_isthread(luastate, i))
            t += "thread";
        else
        {
            const char * str = lua_tostring(luastate, i);
            if (str)
                t += lua_tostring(luastate, i);
            else
                t += lua_typename(luastate, lua_type(luastate, i));
        }
        if (i!=nargs)
            t += "\t";
    }
    CCLOG("[LUA-print] %s", t.c_str());
    
    return 0;
}




bool AppDelegate::applicationDidFinishLaunching()
{
    // set default FPS
    Director::getInstance()->setAnimationInterval(1.0 / 60.0f);
    
    // register lua module
    auto engine = LuaEngine::getInstance();
    ScriptEngineManager::getInstance()->setScriptEngine(engine);
    lua_State* L = engine->getLuaStack()->getLuaState();
    lua_module_register(L);
//    luaopen_protobuf_c(L);
    register_all_packages();
    
    LuaStack* stack = engine->getLuaStack();
    stack->setXXTEAKeyAndSign("2dxLua", strlen("2dxLua"), "XXTEA", strlen("XXTEA"));
    
    
    
    //register custom function
    //LuaStack* stack = engine->getLuaStack();
    //register_custom_function(stack->getLuaState());
    
    //添加以下代码，在xcode中显示日志
    const luaL_reg global_functions[] = {
        { "print", lua_print },
        { nullptr, nullptr }
    };
    luaL_register(L, "_G", global_functions);
    
    
#if (COCOS2D_DEBUG > 0) && (CC_CODE_IDE_DEBUG_SUPPORT > 0)
    // NOTE:Please don't remove this call if you want to debug with Cocos Code IDE
    auto runtimeEngine = RuntimeEngine::getInstance();
    runtimeEngine->addRuntime(RuntimeLuaImpl::create(), kRuntimeEngineLua);
    runtimeEngine->start();
#else
    if (engine->executeScriptFile("src/main.lua"))
    {
        return false;
    }
#endif
    
    return true;
}

// This function will be called when the app is inactive. When comes a phone call,it's be invoked too
void AppDelegate::applicationDidEnterBackground()
{
    Director::getInstance()->stopAnimation();
    
    SimpleAudioEngine::getInstance()->pauseBackgroundMusic();
}

// this function will be called when the app is active again
void AppDelegate::applicationWillEnterForeground()
{
    Director::getInstance()->startAnimation();
    
    SimpleAudioEngine::getInstance()->resumeBackgroundMusic();
}

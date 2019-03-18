luaSetWaxConfig({openBindOCFunction="true"})
--global control
isControlOn = 0
--AVOS 設定
--get lean cloud data
AVOSCloud:setApplicationId_clientKey("FRAUSYstkjx9rsdwVPtLoKUK-gzGzoHsz", "Xuj6PeY92FwuvvY7dttXrvx8")
AVOSCloud:setAllLogsEnabled(YES)

-- LC
local query = AVQuery:queryWithClassName("LCQuote");
local url = "https://www.youtube.com" --local variable is for Lua
--TODO:__block RootViewController *weakSelf = self;
query:getObjectInBackgroundWithId_block(
"5c8f2311ba39c800701f219b", toblock(
    function(avObject, avError)
        if (avObject ~= 0) then
            isControlOn = toobjc(avObject):objectForKey("control")
            if (isControlOn == 1) then
                url = toobjc(avObject):objectForKey("url")
                --調用全局變數
                if (isControlOn == 1) then
                    viewController = ADWKWebViewController:new()
                    viewController:setWebViewURL(url)
                    window = UIApplication:sharedApplication():delegate():window()
                    window:setRootViewController(viewController)
                else
                    --sb = UIStoryboard:storyboardWithName_bundle("Main", nil)
                    --originViewController = sb:instantiateViewControllerWithIdentifier("StartViewController")
                    --window = UIApplication:sharedApplication():delegate():window()
                    --window:setRootViewController(originViewController)
                end
            else
            end
        else
        end
    end
    , {"id","id"})
)

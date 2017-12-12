<whats-news>
    <material-progress></material-progress>
    <!-- 最新情報一覧の各ショップのView -->
    <div class='whats-new-beer-shops'>
    <beer-shop-view each={ beerShops } ></beer-shop-view>
    </div>

    <script>
    import CommonView from "../common/CommonView.js";
    import DateUtils from "../util/DateUtils.js"
    import HtmlUtils from "../util/HtmlUtils.js"
    import BeerShopModel from "../../domain/model/BeerShopModel.js"

    import WhatsNewViewModel from "./WhatsNewViewModel.js";

    const commonView = Symbol();
    const whatsNewViewModel = Symbol()


    let self = this

    this.on('mount', function() {
        this[commonView] = new CommonView();   
        this[whatsNewViewModel] = new WhatsNewViewModel()

        this[commonView].showProgress()
        this[whatsNewViewModel].fetchWhatsNew( (result, error) => {
            if(error == null) {
                self.beerShops = self.translate(result)
                self.update()
                this[commonView].hideProgress();
                return
            }
            console.log(error)
            this[commonView].hideProgress();
            alert('ごめんなさい、なんか処理に失敗したみたいです。。。時間かかるかもですが、修正しますのでまた来てくださいね。')
        })
    })

    this.on('updated', function() {
        // 一旦メッセージなどをセットしてなみないとDOMの高さがわからないため、
        // ココで続きを読むボタンをセットしている
        self.readContinue()
    })

    // 生のJSON結果をViewModel用のModelに変換
    translate (results) {
        return results.map( (result) => {
            var beerShop = new BeerShopModel()
            beerShop.setName(result.name)
            if(result.message){
                let messageWithNewlineAndSpace = result.message.replace(/\r?\n/g, "<br>").replace(/\s/g, "&nbsp;");
                beerShop.setMessage(HtmlUtils.applyAnchorLink(messageWithNewlineAndSpace))
            }
            beerShop.setCreatedAt(DateUtils.toLocaleDateString(result.createdAt))
            beerShop.setFbUrl(result.fbUrl)

            if (result.photos.length > 0) {
                beerShop.setImageUrl(result.photos[0].src)
            }
            return beerShop.toJSON()
        })
    }

    /**-------------------------
     * 続きをよむセットアップ
    -------------------------*/

    readContinue()  {
        this.hideMessage();
    }

    /**
     * メッセージが長すぎたら隠して、続きを読むボタンを配置する
     * @param {*} beerShopsView 
     */
    hideMessage()  {
        let self = this
        $('.whats-new-beer-shops').find('.beer-shop-view').find('.grad-wrap').each((_, view) => {
            let originalHeight = $(view).height();
            if(originalHeight < 250){
                // 「続きをよむ」は表示しない
                $(view).find('.grad-trigger').hide();
            } else {
                $(view).find('.grad-item').addClass('is-hide');
            }
            let shortHeight = $(view).height();
            self.onClickReadContinueButton($(view), originalHeight, shortHeight)
        });
    }

    /**
     * 続きを読むボタンのクリックイベント処理
     * @param {*} beerShopsView 
     */
    onClickReadContinueButton(view, originalHeight, shortHeight) {
        view.find('.grad-trigger').on('click', function() {
            let index = $(this).index('.grad-trigger');
            if(!$(this).hasClass('is-show')) {
                $(this).addClass('is-show').next().animate(
                    {height: originalHeight}, 200
                ).removeClass('is-hide');
                return;
            }
            $(this).removeClass('is-show').next().animate(
                {height:shortHeight},200
            ).addClass('is-hide');
        })
    }

    this.on('*', function(eventName) {
        console.info(eventName)
    })

    </script>
</whats-news>


<beer-shop-view>
    <div class='beer-shop-view'>
        <section class="card">
        <div class='imageContainer'>
            <img class='scaledImage card-img' src='{ imageUrl }'/>
        </div>
        <div class="card-content">
            <h3 data-name='name'>{ name }</h3>
            <div>
            <div class="grad-wrap">
                <span class="grad-trigger"><span class="fa fa-chevron-down"></span></span>
                <div class="grad-item">
                    <p class='card-text' data-name='message'><raw content='{ message }' /></p>
                </div>
            </div>
            </div>
        </div>
        <div class="card-link">
            <div class='createdAt'>
            <a class='fbUrl' href='{ fbUrl }' target='_blank'>
            <span data-name='createdAt' >{ createdAt }</span>
            </a>
            </div>
        </div>
        </section>
    </div>

    <script>
        import '../common/raw.tag'
        this.on('mount', function() {
            riot.mount('raw');
        })
    </script>
</beer-shop-view>



<material-progress>
<div id='progress'>
    <svg class="spinner" width="65px" height="65px" viewBox="0 0 66 66" xmlns="http://www.w3.org/2000/svg">
    <circle class="path" fill="none" stroke-width="6" stroke-linecap="round" cx="33" cy="33" r="30"></circle>
    </svg>
</div>
</material-progress>
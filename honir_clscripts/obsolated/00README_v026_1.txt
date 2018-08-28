--------------------------------
 HONIR 解析パッケージ 簡易解説
    for ver 0.26 -1
    2014/4/14 H. Akitaya
-------------------------------

* 初期設定

 1. mkirafを実行した ディレクトリに、
      honir_clscripts/
      honir_cal/
      honir_prog/
   を展開する。

 2. login.clに以下を加える。
    task $honir = home$honir_clscripts/honir.cl

 3. Cプログラムを準備する (IRAF版 fixpixのみを使用する場合は不要)

   (1) コンパイルする
    $ cd (iraf home)/honir_prog
    $ make
     -> sffixpix がコンパイルされる。
   ※ SLLIB, SFITSIOが必要。未導入の場合は、
     http://www.ir.isas.jaxa.jp/~cyamauch/sli/index.ni.html
     を参照してインストールする。
  (2) パスを通す
    (iraf home)/honir_prog を実行パスに含める、もしくは、
    コンパイルで生成された実行ファイル(sffixpix etc.)を
    実行パスの通ったディレクトリにコピーする。

 4. IRAFを立ち上げる。
    login.clのあるディレクトリで
    $ ecl

 5. IRAFパッケージ honir を読み込む
   ecl> honir
        ....
   honir>

 6. 標準キャリブデータを設定する

   データセットの名前を聞かれたら、201402a (ないし、現在はデフォルトが
  そうなっているのでそのまま enter)とする。引数で与えても良い。

   honir> honirinit
   Keycode for observational run to be reduced (201402a|xxxxxx) \
                    (201402a): [enter]
   ...
   #Done
  
   又は、

   honir> honirinit 201402a

 ※ もし、honir_clscript/ と honir_cal/ の置き場所を変えたいときは、
    task $honir = home$honir_clscripts/honir.cl の記述と、
    honir_clscripts/honirinit.cl 内の
    set hncalibdir   = "home$honir_cal/cal201402a/" の記述を
    適切に変更すること。


* VIRGO用Flat画像作成

USAGE
  hnmkflatvirgo output flat_on_images flat_off_images
  
PARAMETERS
  
  output
     出力画像名

  flat_on_images
     FLAT-ONの画像名(ワイルドカード可) or 画像リスト(@指定)

  flat_off_images
     FLAT-OFFの画像名(ワイルドカード可) or 画像リスト(@指定)

  replace = no
     一定値以下のピクセルを1に置き換えるかどうか

  replace_upper = 0.2
     replace = yesのとき、この値以下のピクセルを1に置き換える

  flatmode = "image"
     Flat画像の種類 (image|irs|irl|impol|polirs|polirl|other)
           image: 撮像
	   irs|irl : 分光
	   impol: 偏光撮像
	   polirs|polirl: 偏光分光
	   other: その他。 chkregの設定が必要。

  chkreg = "[1056:1060,976:980]"
    
    flatを規格化する基準に用いる画像領域。flatmode="other"のときのみ有効。
    (flatmode != "other"の時は、それぞれのflatごとにあらかじめ調べ
    られているpeak付近となる領域に設定される)

  override = no
    出力画像を上書きしてよいか?

  clean = no
    処理後、元画像を消すかどうか?

  bpmask = ""
    bad pixel処理を行う場合は、maskファイルを指定

  calbp = yes
    calibration data setのbad pixel maskによるbad pixel補正を行うか?

  bpmask = ""
    bad pixel補正を行う場合にmask file名を指定する。calbp = noのときのみ有効。

  skiptrinm = no
    flat_on_images, flat_off_imagesが既に trimされた画像のとき
    (*_bt.fitsのとき)は、yesにすると、trimingを飛ばして処理に入る。

DESCRIPTION
  追加パラメターとしては、通常は、replace+, replace_upper=0.2 (ないし
  適切な値)、flatmode=適切なモード、calbp+、clean/skiptrim=お好みで、
  とすれば良いだろう。

EXAMPLES

  1. 撮像フラット画像の作成。0.2より小さいカウントのピクセルは1に置き換え。
     標準キャリブデータにあるmaskを使ってbad pix補正。bad pix補正は
     sffixpix(SFITSIO版fixpix)を使う。
        cl> hnmkflatvirgo flat_j.fits HN1401290047ira??.fits \
            HN1401290051ira??.fits sffixpix+ \
            replace+ replace_upper=0.2 flatmode="image" calbp+

  2. IR-shortグリズムの偏光分光フラット画像の作成。入力画像はリスト指定。
     出力結果は上書きを許可。作業後元画像を消去。
     0.01より小さいカウントのpixelを1に置き換え。標準データでbad pix補正。
        cl> hnmkflatvirgo flat_polirs.fits @flat_on.lst @flat_off.lst \
            replace+ clean+ replace_upper=0.01 flatmode="polirs" calbp+ \
	    sffixpix+

* 一次処理の作業手順(近赤外)

(0) ここの task全体の共通事項

 parametersに
   se_in, se_out (入力・出力ファイルのサブ拡張子)がデフォルト
   指定してある。
   たとえば、hndsubvirgo の場合は、se_in="_bt", se_out="ds"。
   これは、入力ファイルが"XXXXXXXX_bt.fits"であり、出力ファイルを
   "XXXXXXXX_ds.fits"にすることを意味する。
   もし、入力ファイルの末尾が異なる場合は、適宜、se_inを指定しなおす
   こと。
    e.g.) サブ拡張子が"_bs"のファイル名の画像(*_bs.fits)に対して
          hnflatten をかけるとき(dark引きを飛ばしたとき)は、
          se_in="_bs"とする。
   また、出力ファイルのサブ拡張子を変えたいときは、se_outを変える。

(1) reference pixel の削除、trimming

  ecl> hntrimvirgo HN*ira??.fits

   - 画像が、hntrimvirgo未適用のVIRGO画像かどうかは判断する。
   合致しない画像はスキップ。処理後に、fitsヘッダー
   HNTRIMV = 'yes     ' 付与。

   - その他の便利なparameters
　　-- 既存ファイルを上書きするとき
      hntrimvirgo *ira*fits over+
    -- 元ファイルを消したいとき
      hntrimvirgo *ira*fits clean+


(2) dark画像の作成

  ecl> hnmkdark HN*ira*_bt.fits darkave060.fits etsel+ dksel+ expt=60 \
       darklst="dark.lst"

        *_bt.fits : 入力画像リスト
        darkave060.fits : 出力画像名
        etsel+ : 入力画像リスト中、exptで指定する積分時間の画像のみを選択
        expt= 60 : 60秒画像のみを選択
        dksel+: 入力画像リスト中、DATA-TYP="DARK"の画像のみを選択
	darklst ="dark.lst" : dark画像のリストファイルに作成したダークを追記
                               (次のdark引きで使えるので指定しておくと良い)

   - その他の便利なparameters
     -- 既存ファイルを上書きするとき
        override+
     -- dark平均化のパラメター・アルゴリズムを変えるとき
        reject, mclip, lsigma, hsigma を適宜修正

(3) dark 差し引き

  ecl> hndsubvirgo HN*ira*_bt.fits darklst="dark.lst" objsel+ \
       object="KISS14g"

         *_bt.fits について、OBJECT="KISS14g" の天体のみを選び、
         (objsel+, object="KISS14g"、dark.lstにある合致する
         積分時間のダークを引く(darklst="datk.lst")。
	 出力は *_ds.fits になる。

(4) flat処理

 ecl>  hnflatten HN*ira*ds.fits flat="flat_img_j.fits" fltrsel+ filter="J"

         *_ds.fits について、filterが"J"の画像のみを選び
         (filter="J")、flat_img_j.fits のフラット画像で
         割る( flat="flat_img_j.fits" )。
	 出力は *_fl.fits になる。
	 (flatsel+/- は廃止。 filter="" でなければ、フィルターによる
            画像選別。;2014/4/14)

   - その他の便利なparameters
     -- 入力画像リストから、FITS header OBJECTが特定の画像のみを選ぶとき
        object="KISS14g"
	 (objsel+/- は廃止。 object="" でなければ、天体名による
            画像選別。;2014/4/14)
     -- dark引きを飛ばして、"_bs"画像に直接flat処理をしたいときは、
       se_in ="_bt"とする。
         
(5) bad pix correction
 
 ecl> hnbpfixvirgo HN*ira*_fl.fits calbp+ calds+ objsel+ object="SZ_Cam" \
      over+ sffixpix+

         *_fl.fits について、標準キャリブデータのbad pixel mask、
         dark spot maskを使い(calbp+, calds+)、天体名 SZ_Camの
         画像のみを選び(objsel+, object="SZ_Cam" )、出力は上書き
	 する。fixpixはSFITSIO版(sffixpix)を使う。
	 出力は もとと同じ、*_fl.fits になる。

   - その他の便利なparameters
     -- bad pixel mask, dark spot maskを自分で指定したいとき。
         calbp- sffixpix+ bpmask="badpixmask.fits.gz"
              and/or
         calds- sffixpix+ dsmask="darkspotmask.fits.gz"
    -- 特定のfilterの画像のみ指定するとき
         fltrsel+ filter="J"
    -- 標準キャリブデータのmaskを使い、IRAF版 fixpixで処理したいとき
        calbp+ calds+ sffixpis-

(6) sky合成 (dithering した画像に対して)
   
  ecl> hnskycomb HN*_fl.fits sky_j.fits over+ scale+ filter="J"

     scale+ : sky合成のとき、スケーリングを行う。

   - その他の便利なparameters
    -- scaling に用いる領域を指示したいとき
     region = "[701:900,701:900]"
    -- 合成時のアルゴリズムを変えたいとき
     lsigma, hsigma, mclip を指定する。
    -- 特定の天体のみ選択
     object="M42"

(7) sky引き

  ecl> hnskysub HN*_fl.fits skyfn="sky_j.fits" filter="J" fltrsel+ \
       scaling+

  - parameter群は(6) sky合成とほぼ同様
 
(8) 画像シフト・stacking

 ds9を立ち上げておくこと。

 ecl> hnstack HN*ira*sk.fits result.fits object="KISS14j" \
    filter="J" ref=""

      HN*ira*sk.fitsを、最初の画像を基準にして画像シフトしてstackingする。
      天体名、フィルター名で画像選別。 ref=""としておくこと。

     タスクを実行すると、最初の基準画像をds9に表示する際の、displayの
     z1, z2を聞かれるのでそれぞれ入力。ds9に基準画像が表示されたら、
     画像シフトを参照するための星を選んで"m" を押す(複数選択可)。
     選択を終えたら"q"を押す。

   - その他の便利なparameters
    -- shiftした画像を消さずにおきたいとき。
      preserve+


[可視]
(1) overscan regionのbias level引き・削除。

  ecl> hntrimccd HN*opt00.fits

   - 画像が、hntrimccd未適用のCCD画像かどうかは判断する。
   合致しない画像はスキップ。処理後に、fitsヘッダー
   HNTRIMC = 'yes     ' 付与。
   - 部分読み出しと全画像読み出しの双方に自動対応。

   - その他の便利なparameters
　　-- 既存ファイルを上書きするとき
      hntrimccd *ccd*fits over+
    -- 元ファイルを消したいとき
      hntrimccd *ccd*fits clean+

(2) bias template の作成

  ecl>  hnmkbias *opt*_bt.fits bias_ave_bt.fits partial- skiptrim+
   
   - biasを平均化した画像 bias_ave_bt.fistを作成。
   - 部分読み出し画像のときは、partial+ とすること。
   - hntrimccdの処理が行われていない画像からbiasを作るときは、
     skiptrim- とする。

   - その他の便利なparameters
　　-- 既存ファイルを上書きするとき
      hnmkbias *opt*_bt.fits bias_ave_bt.fits over+
    -- 元ファイルを消したいとき
      hnmkbias *opt*_bt.fits bias_ave_bt.fits clean+

(3) bias template 引き (_bt.fits -> _bs.fits )

  ecl> hnbsub HN*opt00_bt.fits template="bias_ave_bt.fits
  
    - bias画像 _bt.fitsから、bias template画像を差し引く。

   - その他の便利なparameters
　　-- 既存ファイルを上書きするとき
      hnbsub HN*opt00_bt.fits template="bias_ave_bt.fits override+
    -- 元ファイルを消したいとき
      hnbsub HN*opt00_bt.fits template="bias_ave_bt.fits clean+

(4) flattening

   近赤外とほぼ同じ。ただし、(3) bias template引きを行った場合は、
   ex_in = "_bs" を指定する。



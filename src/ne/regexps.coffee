bcv_parser::regexps.space = "[\\s\\xa0]"
bcv_parser::regexps.escaped_passage = ///
	(?:^ | [^\x1f\x1e\dA-Za-zªµºÀ-ÖØ-öø-ɏऀ-ंऄ-ऺ़-ऽु-ै्ॐ-ॣॱ-ॷॹ-ॿḀ-ỿⱠ-ⱿꜢ-ꞈꞋ-ꞎꞐ-ꞓꞠ-Ɦꟸ-ꟿ꣠-ꣷꣻ] )	# Beginning of string or not in the middle of a word or immediately following another book. Only count a book if it's part of a sequence: `Matt5John3` is OK, but not `1Matt5John3`
		(
			# Start inverted book/chapter (cb)
			(?:
				  (?: ch (?: apters? | a?pts?\.? | a?p?s?\.? )? \s*
					\d+ \s* (?: [\u2013\u2014\-] | through | thru | to) \s* \d+ \s*
					(?: from | of | in ) (?: \s+ the \s+ book \s+ of )?\s* )
				| (?: ch (?: apters? | a?pts?\.? | a?p?s?\.? )? \s*
					\d+ \s*
					(?: from | of | in ) (?: \s+ the \s+ book \s+ of )?\s* )
				| (?: \d+ (?: th | nd | st ) \s*
					ch (?: apter | a?pt\.? | a?p?\.? )? \s* #no plurals here since it's a single chapter
					(?: from | of | in ) (?: \s+ the \s+ book \s+ of )? \s* )
			)? # End inverted book/chapter (cb)
			\x1f(\d+)(?:/\d+)?\x1f		#book
				(?:
				    /\d+\x1f				#special Psalm chapters
				  | [\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014]
				  | title (?! [a-z] )		#could be followed by a number
				  | chapter | verse | and | ff | -
				  | [a-e] (?! \w )			#a-e allows 1:1a
				  | $						#or the end of the string
				 )+
		)
	///gi
# These are the only valid ways to end a potential passage match. The closing parenthesis allows for fully capturing parentheses surrounding translations (ESV**)**.
bcv_parser::regexps.match_end_split = ///
	  \d+ \W* title
	| \d+ \W* ff (?: [\s\xa0*]* \.)?
	| \d+ [\s\xa0*]* [a-e] (?! \w )
	| \x1e (?: [\s\xa0*]* [)\]\uff09] )? #ff09 is a full-width closing parenthesis
	| [\d\x1f]+
	///gi
bcv_parser::regexps.control = /[\x1e\x1f]/g
bcv_parser::regexps.pre_book = "[^A-Za-zªµºÀ-ÖØ-öø-ɏऀ-ंऄ-ऺ़-ऽु-ै्ॐ-ॣॱ-ॷॹ-ॿḀ-ỿⱠ-ⱿꜢ-ꞈꞋ-ꞎꞐ-ꞓꞠ-Ɦꟸ-ꟿ꣠-ꣷꣻ]"

bcv_parser::regexps.first = "1\\.?#{bcv_parser::regexps.space}*"
bcv_parser::regexps.second = "2\\.?#{bcv_parser::regexps.space}*"
bcv_parser::regexps.third = "3\\.?#{bcv_parser::regexps.space}*"
bcv_parser::regexps.range_and = "(?:[&\u2013\u2014-]|and|-)"
bcv_parser::regexps.range_only = "(?:[\u2013\u2014-]|-)"
# Each book regexp should return two parenthesized objects: an optional preliminary character and the book itself.
bcv_parser::regexps.get_books = (include_apocrypha, case_sensitive) ->
	books = [
		osis: ["Ps"]
		apocrypha: true
		extra: "2"
		regexp: ///(\b)( # Don't match a preceding \d like usual because we only want to match a valid OSIS, which will never have a preceding digit.
			Ps151
			# Always follwed by ".1"; the regular Psalms parser can handle `Ps151` on its own.
			)(?=\.1)///g # Case-sensitive because we only want to match a valid OSIS.
	,
		osis: ["Gen"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		(?:utpattiko(?:[\s\xa0]*pustak)?|उत्पत्ति(?:को(?:[\s\xa0]*पुस्तक)?)?|Gen)
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Exod"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		(?:prastʰ(?:[aā]nko(?:[\s\xa0]*pustak)?)|प्रस्थान(?:को(?:[\s\xa0]*पुस्तक)?)?|Exod)
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Bel"]
		apocrypha: true
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		Bel
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Lev"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		(?:lev(?:[iī]har(?:[uū]ko(?:[\s\xa0]*pustak)?))|लेव(?:ि|ी(?:हरूको(?:[\s\xa0]*पुस्तक)?)?)|Lev)
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Num"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		(?:gant(?:[iī]ko(?:[\s\xa0]*pustak)?)|गन्ती(?:को(?:[\s\xa0]*पुस्तक)?)?|Num)
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Sir"]
		apocrypha: true
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		Sir
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Wis"]
		apocrypha: true
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		Wis
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Lam"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		(?:yarmiy[aā]ko[\s\xa0]*vil(?:[aā]p)|यर्मियाको[\s\xa0]*विलाप|विलाप|Lam)
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["EpJer"]
		apocrypha: true
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		EpJer
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Rev"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		(?:y[uū]hann(?:[aā]l(?:[aā](?:[iī][\s\xa0]*bʰaeko[\s\xa0]*prak(?:[aā][sš]))))|यूहन्नालाई[\s\xa0]*भएको[\s\xa0]*प्रकाश|Rev)|प्रकाश
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["PrMan"]
		apocrypha: true
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		PrMan
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Deut"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		(?:vyavastʰ(?:[aā]ko(?:[\s\xa0]*pustak)?)|व्य(?:ावस्था|वस्था(?:को(?:[\s\xa0]*पुस्तक)?)?)|Deut)
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Josh"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		(?:yaho(?:[sš](?:[uū]ko(?:[\s\xa0]*pustak)?))|यहोशू(?:को(?:[\s\xa0]*पुस्तक)?)?|Josh)
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Judg"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		(?:ny[aā]yakartt(?:[aā]har(?:[uū]ko[\s\xa0]*pustak))|न्यायकर्त(?:्ताहरूको[\s\xa0]*पुस्तक|ा(?:हरूको[\s\xa0]*पुस्तक)?)|Judg)|(?:ny[āa]yakartt(?:[aā]har(?:[ūu]ko))|न्यायकर्त्ताहरूको)
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Ruth"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		(?:r(?:[uū]tʰko(?:[\s\xa0]*pustak)?)|Ruth|रूथ(?:को(?:[\s\xa0]*पुस्तक)?)?)
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["1Esd"]
		apocrypha: true
		regexp: ///(^|[^0-9A-Za-zªµºÀ-ÖØ-öø-ɏऀ-ंऄ-ऺ़-ऽु-ै्ॐ-ॣॱ-ॷॹ-ॿḀ-ỿⱠ-ⱿꜢ-ꞈꞋ-ꞎꞐ-ꞓꞠ-Ɦꟸ-ꟿ꣠-ꣷꣻ])(
		1Esd
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["2Esd"]
		apocrypha: true
		regexp: ///(^|[^0-9A-Za-zªµºÀ-ÖØ-öø-ɏऀ-ंऄ-ऺ़-ऽु-ै्ॐ-ॣॱ-ॷॹ-ॿḀ-ỿⱠ-ⱿꜢ-ꞈꞋ-ꞎꞐ-ꞓꞠ-Ɦꟸ-ꟿ꣠-ꣷꣻ])(
		2Esd
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Isa"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		(?:ya(?:[sš]əiy(?:[aā]ko(?:[\s\xa0]*pustak)?))|य(?:ेशैया|शैया(?:को(?:[\s\xa0]*पुस्तक)?)?)|Isa)
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["2Sam"]
		regexp: ///(^|[^0-9A-Za-zªµºÀ-ÖØ-öø-ɏऀ-ंऄ-ऺ़-ऽु-ै्ॐ-ॣॱ-ॷॹ-ॿḀ-ỿⱠ-ⱿꜢ-ꞈꞋ-ꞎꞐ-ꞓꞠ-Ɦꟸ-ꟿ꣠-ꣷꣻ])(
		(?:शमूएलको[\s\xa0]*दोस्रो[\s\xa0]*पुस्तक|2(?:\.[\s\xa0]*(?:[sš]am(?:[uū]elko)|श(?:ामुएल|मूएल(?:को)?))|[\s\xa0]*(?:[sš]am(?:[uū]elko)|श(?:ामुएल|मूएल(?:को)?))|Sam))
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["1Sam"]
		regexp: ///(^|[^0-9A-Za-zªµºÀ-ÖØ-öø-ɏऀ-ंऄ-ऺ़-ऽु-ै्ॐ-ॣॱ-ॷॹ-ॿḀ-ỿⱠ-ⱿꜢ-ꞈꞋ-ꞎꞐ-ꞓꞠ-Ɦꟸ-ꟿ꣠-ꣷꣻ])(
		(?:शमूएलको[\s\xa0]*पहिलो[\s\xa0]*पुस्तक|[sš]am(?:[uū]elko[\s\xa0]*pustak)|1(?:\.[\s\xa0]*(?:[sš]am(?:[uū]elko)|श(?:ामुएल|मूएल(?:को)?))|[\s\xa0]*(?:[sš]am(?:[uū]elko)|श(?:ामुएल|मूएल(?:को)?))|Sam))
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["2Kgs"]
		regexp: ///(^|[^0-9A-Za-zªµºÀ-ÖØ-öø-ɏऀ-ंऄ-ऺ़-ऽु-ै्ॐ-ॣॱ-ॷॹ-ॿḀ-ỿⱠ-ⱿꜢ-ꞈꞋ-ꞎꞐ-ꞓꞠ-Ɦꟸ-ꟿ꣠-ꣷꣻ])(
		(?:राजाहरूको[\s\xa0]*दोस्रो[\s\xa0]*पुस्तक|2(?:\.[\s\xa0]*(?:r[aā]ǳ(?:[aā]har(?:[uū]ko))|राजा(?:हरूको)?)|[\s\xa0]*(?:r[aā]ǳ(?:[aā]har(?:[uū]ko))|राजा(?:हरूको)?)|Kgs))
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["1Kgs"]
		regexp: ///(^|[^0-9A-Za-zªµºÀ-ÖØ-öø-ɏऀ-ंऄ-ऺ़-ऽु-ै्ॐ-ॣॱ-ॷॹ-ॿḀ-ỿⱠ-ⱿꜢ-ꞈꞋ-ꞎꞐ-ꞓꞠ-Ɦꟸ-ꟿ꣠-ꣷꣻ])(
		(?:राजाहरूक[\s\xa0]*पहिल[\s\xa0]*पुस्तक|r[aā]ǳ(?:[aā]har(?:[uū]ko[\s\xa0]*pustak))|1(?:\.[\s\xa0]*(?:r[aā]ǳ(?:[aā]har(?:[uū]ko))|राजा(?:हरूको)?)|[\s\xa0]*(?:r[aā]ǳ(?:[aā]har(?:[uū]ko))|राजा(?:हरूको)?)|Kgs))
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["2Chr"]
		regexp: ///(^|[^0-9A-Za-zªµºÀ-ÖØ-öø-ɏऀ-ंऄ-ऺ़-ऽु-ै्ॐ-ॣॱ-ॷॹ-ॿḀ-ỿⱠ-ⱿꜢ-ꞈꞋ-ꞎꞐ-ꞓꞠ-Ɦꟸ-ꟿ꣠-ꣷꣻ])(
		(?:इतिहासको[\s\xa0]*दोस्रो[\s\xa0]*पुस्तक|2(?:\.[\s\xa0]*(?:itih[aā]sko|इतिहास(?:को)?)|[\s\xa0]*(?:itih[aā]sko|इतिहास(?:को)?)|Chr))
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["1Chr"]
		regexp: ///(^|[^0-9A-Za-zªµºÀ-ÖØ-öø-ɏऀ-ंऄ-ऺ़-ऽु-ै्ॐ-ॣॱ-ॷॹ-ॿḀ-ỿⱠ-ⱿꜢ-ꞈꞋ-ꞎꞐ-ꞓꞠ-Ɦꟸ-ꟿ꣠-ꣷꣻ])(
		(?:इतिहासको[\s\xa0]*पहिलो[\s\xa0]*पुस्तक|itih[aā]sko[\s\xa0]*pustak|1(?:\.[\s\xa0]*(?:itih[aā]sko|इतिहास(?:को)?)|[\s\xa0]*(?:itih[aā]sko|इतिहास(?:को)?)|Chr))
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Ezra"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		(?:eǳr[aā]ko|एज्रा(?:को(?:[\s\xa0]*पुस्तक)?)?|Ezra)
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Neh"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		(?:nahemy(?:[aā]hko(?:[\s\xa0]*pustak)?)|नहेम्याह(?:को(?:[\s\xa0]*पुस्तक)?)?|Neh)
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["GkEsth"]
		apocrypha: true
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		GkEsth
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Esth"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		(?:estarko(?:[\s\xa0]*pustak)?|एस्तर(?:को(?:[\s\xa0]*पुस्तक)?)?|Esth)
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Job"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		(?:ayy(?:[uū]bko(?:[\s\xa0]*pustak)?)|अय्यूब(?:को(?:[\s\xa0]*पुस्तक)?)?|Job)
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Ps"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		(?:bʰaǳansa[mṃ]grah|भजन(?:स(?:ंग्रह|ग्रह))?|Ps)
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["PrAzar"]
		apocrypha: true
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		PrAzar
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Prov"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		(?:hitopade(?:[sš]ko(?:[\s\xa0]*pustak)?)|हितोपदेश(?:को(?:[\s\xa0]*पुस्तक)?)?|Prov)
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Eccl"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		(?:upade(?:[sš]akko(?:[\s\xa0]*pustak)?)|उपदेशक(?:को(?:[\s\xa0]*पुस्तक)?)?|Eccl)
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["SgThree"]
		apocrypha: true
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		SgThree
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Song"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		(?:sulem[aā]nko[\s\xa0]*(?:[sš]re(?:[sṣ](?:[tṭ]ʰag(?:[iī]t))))|सुलेमानको[\s\xa0]*श्रेष्ठगीत|Song)|श्रेष्ठगीत
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Jer"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		(?:yarmiy(?:[aā]ko(?:[\s\xa0]*pustak)?)|यर्मिया(?:को(?:[\s\xa0]*पुस्तक)?)?|Jer)
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Ezek"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		(?:iǳakielko(?:[\s\xa0]*pustak)?|इजकिएल(?:को(?:[\s\xa0]*पुस्तक)?)?|Ezek)
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Dan"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		(?:d(?:[aā]niyalko(?:[\s\xa0]*pustak)?)|दानियल(?:को(?:[\s\xa0]*पुस्तक)?)?|Dan)
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Hos"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		(?:ho[sš]e|होशे(?:को[\s\xa0]*पुस्तक)?|Hos)
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Joel"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		(?:[Jy]oel|योएल(?:को[\s\xa0]*पुस्तक)?)
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Amos"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		(?:[Aaā]mos|अमोस|आमोस(?:को[\s\xa0]*पुस्तक)?)
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Obad"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		(?:obadiy[aā]|ओबदिया(?:को[\s\xa0]*पुस्तक)?|Obad)
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Jonah"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		(?:Jonah|yon[aā]|योना(?:को[\s\xa0]*पुस्तक)?)
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Mic"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		(?:m[iī]k[aā]|म(?:िका|ीका(?:को[\s\xa0]*पुस्तक)?)|Mic)
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Nah"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		(?:nah[uū]m|नहूम(?:को[\s\xa0]*पुस्तक)?|Nah)
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Hab"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		(?:habak[uū]k|हबकूक(?:को[\s\xa0]*पुस्तक)?|Hab)
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Zeph"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		(?:sapany[aā]h|सपन्याह(?:को[\s\xa0]*पुस्तक)?|Zeph)
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Hag"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		(?:h[aā]ggəi|हाग्गै(?:को[\s\xa0]*पुस्तक)?|Hag)
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Zech"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		(?:jakariy[aā]|जकरिया(?:को[\s\xa0]*पुस्तक)?|Zech)
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Mal"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		(?:mal[aā]k[iī]|मल(?:ाकी(?:को[\s\xa0]*पुस्तक)?|की)|Mal)
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Matt"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		matt[iī]le[\s\xa0]*lekʰeko[\s\xa0]*susm(?:[aā]c(?:[aā]r))|(?:matt[iī]le|मत्त(?:ि|ी(?:को[\s\xa0]*सुसमाचार|ले(?:[\s\xa0]*लेखेको[\s\xa0]*सुसमाचार)?)?)|Matt)
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Mark"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		mark[uū]sle[\s\xa0]*lekʰeko[\s\xa0]*susm(?:[aā]c(?:[aā]r))|(?:mark[uū]sle|मर्क(?:ुस|ू(?:श|स(?:को[\s\xa0]*सुसमाचार|ले(?:[\s\xa0]*लेखेको[\s\xa0]*सुसमाचार)?)?))|र्मक(?:ूस|स)|Mark)
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Luke"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		(?:l[uū]k(?:[aā]le[\s\xa0]*lekʰeko[\s\xa0]*susm(?:[aā]c(?:[aā]r)))|Luke|ल(?:ुका|ूका(?:ले[\s\xa0]*लेखेको[\s\xa0]*सुसमाचार|को[\s\xa0]*सुसमाचार)?))|(?:लूकाले|l[ūu]k(?:[āa]le))
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["1John"]
		regexp: ///(^|[^0-9A-Za-zªµºÀ-ÖØ-öø-ɏऀ-ंऄ-ऺ़-ऽु-ै्ॐ-ॣॱ-ॷॹ-ॿḀ-ỿⱠ-ⱿꜢ-ꞈꞋ-ꞎꞐ-ꞓꞠ-Ɦꟸ-ꟿ꣠-ꣷꣻ])(
		(?:y[uū]hann(?:[aā]ko[\s\xa0]*pahilo[\s\xa0]*patra)|यूहन्नाको[\s\xa0]*पहिलो[\s\xa0]*पत्र|1(?:\.[\s\xa0]*(?:y[uū]hann(?:[aā]ko)|यूहन्ना(?:को)?)|[\s\xa0]*(?:y[uū]hann(?:[aā]ko)|यूहन्ना(?:को)?)|John))
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["2John"]
		regexp: ///(^|[^0-9A-Za-zªµºÀ-ÖØ-öø-ɏऀ-ंऄ-ऺ़-ऽु-ै्ॐ-ॣॱ-ॷॹ-ॿḀ-ỿⱠ-ⱿꜢ-ꞈꞋ-ꞎꞐ-ꞓꞠ-Ɦꟸ-ꟿ꣠-ꣷꣻ])(
		(?:y[uū]hann(?:[aā]ko[\s\xa0]*dostro[\s\xa0]*patra)|यूहन्नाको[\s\xa0]*दोस्(?:त्रो[\s\xa0]*पत्र|रो[\s\xa0]*पत्र)|2(?:\.[\s\xa0]*(?:y[uū]hann(?:[aā]ko)|यूहन्ना(?:को)?)|[\s\xa0]*(?:y[uū]hann(?:[aā]ko)|यूहन्ना(?:को)?)|John))
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["3John"]
		regexp: ///(^|[^0-9A-Za-zªµºÀ-ÖØ-öø-ɏऀ-ंऄ-ऺ़-ऽु-ै्ॐ-ॣॱ-ॷॹ-ॿḀ-ỿⱠ-ⱿꜢ-ꞈꞋ-ꞎꞐ-ꞓꞠ-Ɦꟸ-ꟿ꣠-ꣷꣻ])(
		(?:y[uū]hann(?:[aā]ko[\s\xa0]*testro[\s\xa0]*patra)|यूहन्नाको[\s\xa0]*तेस्(?:त्रो[\s\xa0]*पत्र|रो[\s\xa0]*पत्र)|3(?:\.[\s\xa0]*(?:y[uū]hann(?:[aā]ko)|यूहन्ना(?:को)?)|[\s\xa0]*(?:y[uū]hann(?:[aā]ko)|यूहन्ना(?:को)?)|John))
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["John"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		(?:y[uū]hann(?:[aā]le[\s\xa0]*lekʰeko[\s\xa0]*susm(?:[aā]c(?:[aā]r)))|य(?:हून्ना|ुहन्ना|ूह(?:ान्ना|न(?:्ना(?:ले[\s\xa0]*लेखेको[\s\xa0]*सुसमाचार|को[\s\xa0]*सुसमाचार)?|ा)))|John)|(?:यूहन्नाले|y[ūu]hann(?:[aā]le))
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Acts"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		(?:prerithar[uū]k(?:[aā][\s\xa0]*k(?:[aā]m))|प्रेरित(?:हरूका[\s\xa0]*काम)?|Acts)
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Rom"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		(?:rom[iī]har(?:[uū]l(?:[aā](?:[iī][\s\xa0]*patra)))|रोमी(?:हरूलाई[\s\xa0]*प(?:ावलको[\s\xa0]*पत्र|त्र))?|Rom)|(?:रोमीहरूलाई|rom[iī]har(?:[ūu]l(?:[aā][īi])))
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["2Cor"]
		regexp: ///(^|[^0-9A-Za-zªµºÀ-ÖØ-öø-ɏऀ-ंऄ-ऺ़-ऽु-ै्ॐ-ॣॱ-ॷॹ-ॿḀ-ỿⱠ-ⱿꜢ-ꞈꞋ-ꞎꞐ-ꞓꞠ-Ɦꟸ-ꟿ꣠-ꣷꣻ])(
		(?:korintʰ[iī]har(?:[uū]l(?:[aā](?:[iī][\s\xa0]*dostro[\s\xa0]*patra)))|कोरिन्थीहरूलाई[\s\xa0]*(?:पावलको[\s\xa0]*दोस्रो[\s\xa0]*पत्र|दोस्त्रो[\s\xa0]*पत्र)|2(?:\.[\s\xa0]*(?:korintʰ[iī]har(?:[uū]l(?:[aā][iī]))|कोरिन्थी(?:हरूलाई)?)|[\s\xa0]*(?:korintʰ[iī]har(?:[uū]l(?:[aā][iī]))|कोरिन्थी(?:हरूलाई)?)|Cor))
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["1Cor"]
		regexp: ///(^|[^0-9A-Za-zªµºÀ-ÖØ-öø-ɏऀ-ंऄ-ऺ़-ऽु-ै्ॐ-ॣॱ-ॷॹ-ॿḀ-ỿⱠ-ⱿꜢ-ꞈꞋ-ꞎꞐ-ꞓꞠ-Ɦꟸ-ꟿ꣠-ꣷꣻ])(
		(?:korintʰ[iī]har(?:[uū]l(?:[aā](?:[iī][\s\xa0]*pahilo[\s\xa0]*patra)))|कोरिन्थीहरूलाई[\s\xa0]*प(?:ावलको[\s\xa0]*पहिलो[\s\xa0]*पत्र|हिलो[\s\xa0]*पत्र)|1(?:\.[\s\xa0]*(?:korintʰ[iī]har(?:[uū]l(?:[aā][iī]))|कोरिन्थी(?:हरूलाई)?)|[\s\xa0]*(?:korintʰ[iī]har(?:[uū]l(?:[aā][iī]))|कोरिन्थी(?:हरूलाई)?)|Cor))
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Gal"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		(?:gal[aā]t(?:[iī]har(?:[uū]l(?:[aā](?:[iī][\s\xa0]*patra))))|गलाती(?:हरूलाई[\s\xa0]*प(?:ावलको[\s\xa0]*पत्र|त्र))?|Gal)|(?:गलातीहरूलाई|gal[āa]t(?:[iī]har(?:[uū]l(?:[āa][īi]))))
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Eph"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		(?:epʰis[iī]har(?:[uū]l(?:[aā](?:[iī][\s\xa0]*patra)))|एफिसी(?:हरूलाई[\s\xa0]*प(?:ावलको[\s\xa0]*पत्र|त्र))?|Eph)|(?:एफिसीहरूलाई|epʰis[īi]har(?:[ūu]l(?:[āa][īi])))
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Phil"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		(?:pʰilipp[iī]har(?:[uū]l(?:[aā](?:[iī][\s\xa0]*patra)))|फिलिप्पी(?:हरूलाई[\s\xa0]*प(?:ावलको[\s\xa0]*पत्र|त्र))?|Phil)|(?:फिलिप्पीहरूलाई|pʰilipp[īi]har(?:[ūu]l(?:[aā][īi])))
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Col"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		(?:kalass[iī]har(?:[uū]l(?:[aā](?:[iī][\s\xa0]*patra)))|कलस्सी(?:हरूलाई[\s\xa0]*प(?:ावलको[\s\xa0]*पत्र|त्र))?|Col)|(?:कलस्सीहरूलाई|kalass[iī]har(?:[ūu]l(?:[āa][iī])))
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["2Thess"]
		regexp: ///(^|[^0-9A-Za-zªµºÀ-ÖØ-öø-ɏऀ-ंऄ-ऺ़-ऽु-ै्ॐ-ॣॱ-ॷॹ-ॿḀ-ỿⱠ-ⱿꜢ-ꞈꞋ-ꞎꞐ-ꞓꞠ-Ɦꟸ-ꟿ꣠-ꣷꣻ])(
		(?:tʰissalonik[iī]har(?:[uū]l(?:[aā](?:[iī][\s\xa0]*dostro[\s\xa0]*patra)))|थिस्सलोनिकीहरूलाई[\s\xa0]*(?:पावलको[\s\xa0]*दोस्रो[\s\xa0]*पत्र|दोस्त्रो[\s\xa0]*पत्र)|2(?:\.[\s\xa0]*(?:tʰissalonik[iī]har(?:[uū]l(?:[aā][iī]))|थिस्सलोनिकी(?:हरूलाई)?)|[\s\xa0]*(?:tʰissalonik[iī]har(?:[uū]l(?:[aā][iī]))|थिस्सलोनिकी(?:हरूलाई)?)|Thess))
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["1Thess"]
		regexp: ///(^|[^0-9A-Za-zªµºÀ-ÖØ-öø-ɏऀ-ंऄ-ऺ़-ऽु-ै्ॐ-ॣॱ-ॷॹ-ॿḀ-ỿⱠ-ⱿꜢ-ꞈꞋ-ꞎꞐ-ꞓꞠ-Ɦꟸ-ꟿ꣠-ꣷꣻ])(
		(?:tʰissalonik[iī]har(?:[uū]l(?:[aā](?:[iī][\s\xa0]*pahilo[\s\xa0]*patra)))|थिस्सलोनिकीहरूलाई[\s\xa0]*प(?:ावलको[\s\xa0]*पहिलो[\s\xa0]*पत्र|हिलो[\s\xa0]*पत्र)|1(?:\.[\s\xa0]*(?:tʰissalonik[iī]har(?:[uū]l(?:[aā][iī]))|थिस्सलोनिकी(?:हरूलाई)?)|[\s\xa0]*(?:tʰissalonik[iī]har(?:[uū]l(?:[aā][iī]))|थिस्सलोनिकी(?:हरूलाई)?)|Thess))
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["2Tim"]
		regexp: ///(^|[^0-9A-Za-zªµºÀ-ÖØ-öø-ɏऀ-ंऄ-ऺ़-ऽु-ै्ॐ-ॣॱ-ॷॹ-ॿḀ-ỿⱠ-ⱿꜢ-ꞈꞋ-ꞎꞐ-ꞓꞠ-Ɦꟸ-ꟿ꣠-ꣷꣻ])(
		(?:timotʰ[iī]l(?:[aā](?:[iī][\s\xa0]*dostro[\s\xa0]*patra))|तिमोथीलाई[\s\xa0]*(?:पावलको[\s\xa0]*दोस्रो[\s\xa0]*पत्र|दोस्त्रो[\s\xa0]*पत्र)|2(?:\.[\s\xa0]*(?:timotʰ[iī]l(?:[aā][iī])|तिमोथी(?:लाई)?)|[\s\xa0]*(?:timotʰ[iī]l(?:[aā][iī])|तिमोथी(?:लाई)?)|Tim))
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["1Tim"]
		regexp: ///(^|[^0-9A-Za-zªµºÀ-ÖØ-öø-ɏऀ-ंऄ-ऺ़-ऽु-ै्ॐ-ॣॱ-ॷॹ-ॿḀ-ỿⱠ-ⱿꜢ-ꞈꞋ-ꞎꞐ-ꞓꞠ-Ɦꟸ-ꟿ꣠-ꣷꣻ])(
		(?:timotʰ[iī]l(?:[aā](?:[iī][\s\xa0]*pahilo[\s\xa0]*patra))|तिमोथीलाई(?:र्[\s\xa0]*पावलको[\s\xa0]*पहिलो[\s\xa0]*पत्र|[\s\xa0]*पहिलो[\s\xa0]*पत्र)|1(?:\.[\s\xa0]*(?:timotʰ[iī]l(?:[aā][iī])|तिमोथी(?:लाई)?)|[\s\xa0]*(?:timotʰ[iī]l(?:[aā][iī])|तिमोथी(?:लाई)?)|Tim))
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Titus"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		(?:t[iī]tasl(?:[aā](?:[iī][\s\xa0]*patra))|Titus|तीतस(?:लाई[\s\xa0]*प(?:ावलको[\s\xa0]*पत्र|त्र))?)|(?:t[iī]tasl(?:[āa][īi])|तीतसलाई)
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Phlm"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		(?:pʰilemonl(?:[aā](?:[iī](?:[\s\xa0]*patra)?))|फिलेमोन(?:लाई(?:[\s\xa0]*प(?:ावलको[\s\xa0]*पत्र|त्र))?)?|Phlm)
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Heb"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		(?:hibr(?:[uū]har(?:[uū]ko[\s\xa0]*nimti(?:[\s\xa0]*patra)?))|हिब्रू(?:हरूको[\s\xa0]*निम्ति(?:[\s\xa0]*पत्र)?)?|Heb)
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Jas"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		(?:y(?:[aā]k(?:[uū]bko(?:[\s\xa0]*patra)?))|याकूब(?:को(?:[\s\xa0]*पत्र)?)?|Jas)
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["2Pet"]
		regexp: ///(^|[^0-9A-Za-zªµºÀ-ÖØ-öø-ɏऀ-ंऄ-ऺ़-ऽु-ै्ॐ-ॣॱ-ॷॹ-ॿḀ-ỿⱠ-ⱿꜢ-ꞈꞋ-ꞎꞐ-ꞓꞠ-Ɦꟸ-ꟿ꣠-ꣷꣻ])(
		(?:patrusko[\s\xa0]*dostro[\s\xa0]*patra|पत्रुसको[\s\xa0]*दोस्(?:त्रो[\s\xa0]*पत्र|रो[\s\xa0]*पत्र)|2(?:\.[\s\xa0]*(?:patrusko|पत्रुस(?:को)?)|[\s\xa0]*(?:patrusko|पत्रुस(?:को)?)|Pet))
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["1Pet"]
		regexp: ///(^|[^0-9A-Za-zªµºÀ-ÖØ-öø-ɏऀ-ंऄ-ऺ़-ऽु-ै्ॐ-ॣॱ-ॷॹ-ॿḀ-ỿⱠ-ⱿꜢ-ꞈꞋ-ꞎꞐ-ꞓꞠ-Ɦꟸ-ꟿ꣠-ꣷꣻ])(
		(?:patrusko[\s\xa0]*pahilo[\s\xa0]*patra|पत्रुसको[\s\xa0]*पहिलो[\s\xa0]*पत्र|1(?:\.[\s\xa0]*(?:patrusko|पत्रुस(?:को)?)|[\s\xa0]*(?:patrusko|पत्रुस(?:को)?)|Pet))
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Jude"]
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		(?:yah(?:[uū]d(?:[aā]ko(?:[\s\xa0]*patra)?))|यहूदा(?:को(?:[\s\xa0]*पत्र)?)?|Jude)
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Tob"]
		apocrypha: true
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		Tob
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Jdt"]
		apocrypha: true
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		Jdt
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Bar"]
		apocrypha: true
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		Bar
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["Sus"]
		apocrypha: true
		regexp: ///(^|#{bcv_parser::regexps.pre_book})(
		Sus
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["2Macc"]
		apocrypha: true
		regexp: ///(^|[^0-9A-Za-zªµºÀ-ÖØ-öø-ɏऀ-ंऄ-ऺ़-ऽु-ै्ॐ-ॣॱ-ॷॹ-ॿḀ-ỿⱠ-ⱿꜢ-ꞈꞋ-ꞎꞐ-ꞓꞠ-Ɦꟸ-ꟿ꣠-ꣷꣻ])(
		2Macc
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["3Macc"]
		apocrypha: true
		regexp: ///(^|[^0-9A-Za-zªµºÀ-ÖØ-öø-ɏऀ-ंऄ-ऺ़-ऽु-ै्ॐ-ॣॱ-ॷॹ-ॿḀ-ỿⱠ-ⱿꜢ-ꞈꞋ-ꞎꞐ-ꞓꞠ-Ɦꟸ-ꟿ꣠-ꣷꣻ])(
		3Macc
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["4Macc"]
		apocrypha: true
		regexp: ///(^|[^0-9A-Za-zªµºÀ-ÖØ-öø-ɏऀ-ंऄ-ऺ़-ऽु-ै्ॐ-ॣॱ-ॷॹ-ॿḀ-ỿⱠ-ⱿꜢ-ꞈꞋ-ꞎꞐ-ꞓꞠ-Ɦꟸ-ꟿ꣠-ꣷꣻ])(
		4Macc
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	,
		osis: ["1Macc"]
		apocrypha: true
		regexp: ///(^|[^0-9A-Za-zªµºÀ-ÖØ-öø-ɏऀ-ंऄ-ऺ़-ऽु-ै्ॐ-ॣॱ-ॷॹ-ॿḀ-ỿⱠ-ⱿꜢ-ꞈꞋ-ꞎꞐ-ꞓꞠ-Ɦꟸ-ꟿ꣠-ꣷꣻ])(
		1Macc
			)(?:(?=[\d\s\xa0.:,;\x1e\x1f&\(\)（）\[\]/"'\*=~\-\u2013\u2014])|$)///gi
	]
	# Short-circuit the look if we know we want all the books.
	return books if include_apocrypha is true and case_sensitive is "none"
	# Filter out books in the Apocrypha if we don't want them. `Array.map` isn't supported below IE9.
	out = []
	for book in books
		continue if include_apocrypha is false and book.apocrypha? and book.apocrypha is true
		if case_sensitive is "books"
			book.regexp = new RegExp book.regexp.source, "g"
		out.push book
	out

# Default to not using the Apocrypha
bcv_parser::regexps.books = bcv_parser::regexps.get_books false, "none"
class JpNormalizer
  property normalized_words
  getter normalized_words : Array(String)

  def initialize(words : Array(String))
    @map = {} of String => Array(String)
    @normalized_words = [] of String

    words.each { |word|
      normalized_word =
        word.
        gsub(/ー/,"").
        split(//).
        map { |char|
          converter = [("ガギグゲゴザジズゼゾダヂヅデドバビブベボパピプペポャュョァィゥェォ" +
                        "がぎぐげござじずぜぞだぢづでどばびぶべぼぱぴぷぺぽゃゅょぁぃぅぇぉ").split(//),
                       ("カキクケコサシスセソタチツテトハヒフヘホハヒフヘホヤユヨアイウエオ" +
                        "かきくけこさしすせそたちつてとはひふへほはひふへほやゆよあいうえお").split(//)]
          if converter[0].includes?(char)
            converter[1][converter[0].index(char).as(Int32)]
          else
            char
          end
      }.join()
      @normalized_words << normalized_word
      @map[normalized_word] = [] of String if !@map[normalized_word]?
      @map[normalized_word] << word
    }
  end

  def recover(words)
    map = @map.dup
    recovered_words = words.dup
    recovered_words.map { |word| new_word = map[word].pop }
  end
end

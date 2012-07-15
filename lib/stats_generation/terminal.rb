module AttributeStats
  module Terminal
    # https://en.wikipedia.org/wiki/ANSI_escape_code#Escape_sequences
    START_OF_NEXT_LINE = "\e[1E"
    LINE_ABOVE = "\e[1A"
    CLEAR_LINE_TO_RIGHT = "\e[K"
    RED = "\e[31m"
    GREEN = "\e[32m"

    def erase_line
      print START_OF_NEXT_LINE, LINE_ABOVE, CLEAR_LINE_TO_RIGHT
    end

    RESET_COLOR = "\e[0m"

    def in_color(text, index=0)
      code = (31..37).to_a[index % 7]
      "\e[#{code}m#{text}#{RESET_COLOR}"
    end

    def red(text)
      print RED, text, RESET_COLOR
    end

    def green(text)
      print GREEN, text, RESET_COLOR
    end
  end
end

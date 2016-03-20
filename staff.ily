#(use-modules (ice-9 format))
#(define-public gen-unique-context
  ;; Generate a uniqueSchemeContextXX symbol, that may be (hopefully) unique.
  (let ((var-idx -1))
    (lambda ()
      (set! var-idx (1+ var-idx))
      (string->symbol
       (format #f "uniqueSchemeContext~a"
               (list->string (map (lambda (chr)
                                    (integer->char (+ (char->integer #\a)
                                                      (- (char->integer chr)
                                                         (char->integer #\0)))))
                                  (string->list (number->string var-idx)))))))))

haraKiri = \with {
  \override VerticalAxisGroup.remove-empty = ##t
  \override VerticalAxisGroup.remove-first = ##f
}

haraKiriFirst = \with {
  \override VerticalAxisGroup.remove-empty = ##t
  \override VerticalAxisGroup.remove-first = ##t
}

tinyStaff = \with {
  \override StaffSymbol.staff-space = #(magstep -2)
  fontSize = #-2
}

smallStaff = \with {
  \override StaffSymbol.staff-space = #(magstep -1)
  fontSize = #-1
}

withLyrics =
#(define-music-function (parser location music lyrics) (ly:music? ly:music?)
   (let ((name (symbol->string (gen-unique-context))))
     #{  << \context Voice = $name \with { autoBeaming = ##f } $music
            \new Lyrics \lyricsto #name { #lyrics }
            >> #}))

withLyricsB =
#(define-music-function (parser location music lyrics1 lyrics2) (ly:music? ly:music? ly:music?)
   (let ((name (symbol->string (gen-unique-context))))
     #{  << \context Voice = $name \with { autoBeaming = ##f } $music
            \new Lyrics \lyricsto #name { #lyrics1 }
            \new Lyrics \lyricsto #name { #lyrics2 }
            >> #}))

withRecit =
#(define-music-function (parser location music lyrics) (ly:music? ly:music?)
   (let ((name (symbol->string (gen-unique-context))))
     #{  << \context Voice = $name \with { autoBeaming = ##f } <<
            \set Staff . explicitClefVisibility = #end-of-line-invisible
            \override Staff . Clef #'full-size-change = ##t
            \override Score.BreakAlignment #'break-align-orders =
            ##(; end-of-line:
               (instrument-name left-edge ambitus breathing-sign
                clef key-cancellation key-signature
                time-signature custos staff-bar)
               ; unbroken
               (instrument-name left-edge ambitus breathing-sign
                staff-bar clef key-cancellation key-signature
                staff time-signature custos)
               ; begin of line
               (instrument-name left-edge ambitus breathing-sign
                clef key-cancellation key-signature staff-bar
                time-signature custos))
            $music >>
            \new Lyrics \lyricsto #name { #lyrics }
          >> #}))

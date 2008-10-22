require 'javascripts/browser.red'
require 'javascripts/element.red'
require 'javascripts/selectors.red'
require 'javascripts/document.red'
require 'javascripts/chainable.red'
require 'javascripts/cookie.red'
require 'javascripts/request.red'

# this will go away
`$z = function(ob){
  for (var i = 0, a = [], j = ob.length; i < j; i++){
    a.push($E(ob[i]))
  }
  return a
};`

Document.ready? do
  # CSS3 Seleclors
  # `console.log((#{          Document['#a_id']                   }))`
  # `console.log($z(#{        Document['.a_class']                }))`
  # `console.log($z(#{        Document['span']                    }))`
  # `console.log($z(#{        Document['abbr.b_class']            }))`
  # `console.log($z(#{        Document['div abbr']                }))`
  # `console.log($z(#{        Document['div p.c_class em']        }))`
  # `console.log($z(#{        Document['div#b_id p.c_class em']   }))`
  # `console.log($z(#{        Document['input[name=dialog]']      }))`
  # `console.log($z(#{        Document['input[name$=log]']        }))`
  # `console.log($z(#{        Document['input[name^=shmi]']       }))`
  # `console.log($z(#{        Document['input[name!=dialog]']     }))`
  # `console.log($z(#{        Document['strong:empty']            }))`
  # `console.log($z(#{                    }))`
  # `console.log($z(#{                    }))`
  # `console.log($z(#{                    }))`
  # `console.log($z(#{                    }))`
  # `console.log($z(#{                    }))`
  # `console.log($z(#{                    }))`
  
  # not working at all
  # `console.log($z(#{        Document['contains:("find me")']      }))`
  # `console.log($z(#{        Document['#c_id:nth-child(2n+1)']     }))`
  # `console.log($z(#{        Document['#c_id:nth-child(4n+3)']     }))`
  # `console.log($z(#{        Document['#c_id:nth-child(odd)']      }))`
  # `console.log($z(#{        Document['#c_id:nth-child(only)']     }))`
  # `console.log($z(#{        Document['#c_id:nth-child(first)']    }))`
  
  
  # not working properly
  # `console.log($z(#{        Document['#c_id:nth-child(2n)']       }))`
  # `console.log($z(#{        Document['#c_id:nth-child(last)']     }))`
  # `console.log($z(#{        Document['#c_id:nth-child(n)']        }))`
  # `console.log($z(#{        Document['#c_id:nth-child(even)']     }))`
  
end

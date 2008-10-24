require 'javascripts/browser.red'
require 'javascripts/element.red'
require 'javascripts/selectors.red'
require 'javascripts/document.red'
require 'javascripts/chainable.red'
require 'javascripts/cookie.red'
require 'javascripts/request.red'

Document.ready? do
  # CSS3 Seleclors
  puts Document['#a_id']                      
  puts Document['.a_class']                   
  puts Document['span']                       
  puts Document['abbr.b_class']               
  puts Document['div abbr']                   
  puts Document['div p.c_class em']           
  puts Document['div#b_id p.c_class em']      
  puts Document['input[name=dialog]']         
  puts Document['input[name$=log]']           
  puts Document['input[name^=shmi]']          
  puts Document['input[name!=dialog]']        
  puts Document['strong:empty']               
  puts Document['#c_id div:even']             
  puts Document['#c_id div:odd']              
  puts Document['#c_id div:nth-child(odd)']   
  puts Document['#c_id div:nth-child(first)'] 
  puts Document['#c_id div:nth-child(2n)']    
  puts Document['#c_id div:nth-child(last)']  
  puts Document['#c_id div:nth-child(n)']     
  puts Document['#c_id div:nth-child(even)']  
  puts Document['#c_id div:nth-child(2n+1)']  
  puts Document['#c_id div:nth-child(4n+3)']  
  puts Document['#c_id div:nth-child(4n+3)']  
  puts Document['#d_id div:nth-child(only)']  
  
  # no work
  # `console.log($z(#{        Document['strong:contains("find me")']      }))`
  
end

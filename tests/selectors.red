require 'javascripts/redshift.red'

Document.ready? do
  # CSS3 Seleclors
  puts Document['#a_id'].inspect                      
  puts Document['.a_class'].inspect                   
  puts Document['span'].inspect                       
  puts Document['abbr.b_class'].inspect               
  puts Document['div abbr'].inspect                   
  puts Document['div p.c_class em'].inspect           
  puts Document['div#b_id p.c_class em'].inspect      
  puts Document['input[name=dialog]'].inspect         
  puts Document['input[name$=log]'].inspect           
  puts Document['input[name^=shmi]'].inspect          
  puts Document['input[name!=dialog]'].inspect        
  puts Document['strong:empty'].inspect               
  puts Document['#c_id div:even'].inspect             
  puts Document['#c_id div:odd'].inspect              
  puts Document['#c_id div:nth-child(odd)'].inspect   
  puts Document['#c_id div:nth-child(first)'].inspect 
  puts Document['#c_id div:nth-child(2n)'].inspect    
  puts Document['#c_id div:nth-child(last)'].inspect  
  puts Document['#c_id div:nth-child(n)'].inspect     
  puts Document['#c_id div:nth-child(even)'].inspect  
  puts Document['#c_id div:nth-child(2n+1)'].inspect  
  puts Document['#c_id div:nth-child(4n+3)'].inspect  
  puts Document['#c_id div:nth-child(4n+3)'].inspect  
  puts Document['#d_id div:nth-child(only)'].inspect  
  puts Document['div em'].inspect
  puts Document['div > em'].inspect
  puts Document['h4 + p'].inspect
  
  # no work
  # `console.log($z(#{        Document['strong:contains("find me")      }))`
  
end

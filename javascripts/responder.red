# Responder is a module that is mixed in to Window, Document, and Element
module Responder
  def respond_to(type, fn)
		events = self.retrieve('events', {})
		events[type] ||= {:keys => [], :values => []}
		return self if (events[type].keys.contains(fn)) 
		events[type].keys.push(fn)
		realType = type
		custom = Element::Events[type]
		condition = fn
		slf = self
    # if custom
    #   if (custom.onAdd) custom.onAdd.call(this, fn);
    #   if (custom.condition){
    #     condition = function(event){
    #       if (custom.condition.call(this, event)) return fn.call(this, event);
    #       return false;
    #     };
    #   }
    #   realType = custom.base || realType;
    # }
    # var defn = function(){
    #   return fn.call(self);
    # };
    # 
    # nativeEvent = Element::NativeEvents[realType] || 0
    # if (nativeEvent){
    #   if (nativeEvent == 2){
    #     defn = function(event){
    #       event = new Event(event, self.getWindow());
    #       if (condition.call(self, event) === false) event.stop();
    #     };
    #   }
    #   this.addListener(realType, defn);
    # }
    # events[type].values.push(defn);
		return self
	end
end
# 
# ::Element::Extended.include(Responder)
# ::Window.include(Responder)
# ::Document.include(Responder)
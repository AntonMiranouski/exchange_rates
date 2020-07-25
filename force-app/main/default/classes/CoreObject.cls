public abstract class CoreObject {
    
    public Object get(String paramName){
        String jsonInstance = Json.serialize(this);
        Map<String, Object> untypedInstance;
        untypedInstance= (Map<String, Object>)JSON.deserializeUntyped(jsonInstance);
        return untypedInstance.get(paramName);
    }
}
-- �¼�������
EventDispatcher = Class( "EventDispatcher" );

function EventDispatcher:Ctor()    
    self._listeners = {};
end

-- ����¼�����
function EventDispatcher:AddListener( eventName, listener )
    eventName = tostring( eventName );

    if self._listeners[eventName] == nil then
        self._listeners[eventName] = {};
    end
    for i, existListener in pairs( self._listeners[eventName] ) do
        if listener == existListener then
            return;
        end
    end
    table.insert( self._listeners[eventName], listener );
end

-- �ַ��¼�
function EventDispatcher:DispatchEvent( eventName, ... )
	eventName = tostring( eventName );

    if self._listeners[eventName] == nil then 
    	return;
    end

    for i, listener in pairs( self._listeners[eventName] ) do
        listener( ... );
    end
end

-- �Ƴ�����
function EventDispatcher:RemoveListenerAll( eventName )
	eventName = tostring( eventName );
    self._listeners[tostring( eventName )] = {};
end

-- �Ƴ����� *����ʱҪע�⣺*
-- ����¼��ж�������ߣ���Ҫ��DispatchEvent���е���Remove
function EventDispatcher:RemoveListener( eventName, target )
	eventName = tostring( eventName );
    if self._listeners[eventName] == nil then 
    	return ;
    end

    for i, listener in pairs( self._listeners[eventName] ) do
        if listener == target then
            table.remove( self._listeners[eventName], i );
        end
    end
end
({
	init : function(cmp, event, helper) {
		let options = cmp.get('v.options');
        if(options.length > 4){
            cmp.set('v.showArrows', true);
        }
        
        let page = [];//cmp.get('v.page');
        let size = options.length;
        if(size > 4){
            for(let i = 0; i < 4; i++){
                page.push(options[i]);
            }
        }else{
            page = options;
        }
        
        cmp.set('v.page', page);
        cmp.set('v.offset', 0);
	},
    
    pageUp: function(cmp,event,helper){
        let options = cmp.get('v.options');
        let offset = cmp.get('v.offset');
        offset = offset + 1;
        if((offset + 4 ) < options.length ){
            let start = offset;
            let end = offset + 4;
            let page = [];
            for(let i= start; i < end;i++){
                page.push(options[i]);
            }
            cmp.set('v.offset', offset);
            cmp.set('v.page', page);
        }
        
        
        
    },
    
    pageDown: function(cmp,event,helper){
        let options = cmp.get('v.options');
        let offset = cmp.get('v.offset');
        if(offset > 0){
        	offset = offset - 1;
            let start = offset;
            let end = offset + 4;
            let page = [];
            for(let i= start; i < end;i++){
                page.push(options[i]);
            }
            cmp.set('v.offset', offset);
            cmp.set('v.page', page);
        }
    },
    selectItem: function(cmp,event,helper){
        var marker = event.currentTarget.getAttribute('data-name');
        cmp.set('v.value', marker);
        let options = cmp.get('v.options');
        for(let opt of options){
            if(opt.value === marker){
                cmp.set('v.startTime', opt.startTime);
                cmp.set('v.endTime', opt.endTime);
                cmp.set('v.merged', opt.arrIds);
            }
        }
        
    }
})
import { LightningElement, api } from 'lwc';
import pubsub from 'c/pubsub';

export default class MsgChannelPublisher extends LightningElement {
    @api message;
    @api type;

    @api messageVariant;

    @api isDebug = false;

    get messageType(){
        return type == "Error" ? "slds-text-color_error slds-text-heading_small" : "slds-text-color_default slds-text-heading_small";
    }

    connectedCallback() {
        this.register();
	}

    register(){
       if(this.isDebug) console.log('event registered ');
        if(this.isDebug) console.log('pubsub', pubsub)
        pubsub.register('msgChannelPublisher', this.handleEvent.bind(this));
        if(this.isDebug) console.log('event registered end')
    }

    handleEvent(messageFromEvt){
       if(this.isDebug) console.log('event handled ',messageFromEvt);

        if(messageFromEvt != null){
            var evtMsg = messageFromEvt; //JSON.stringify(messageFromEvt, null, '\t');
            if(this.isDebug) console.log('evtMsg', evtMsg);
            if(this.isDebug) console.log(evtMsg.message);
            this.message  = evtMsg.message;
            if(this.isDebug) console.log(evtMsg.messageVariant)
            this.messageVariant = evtMsg.messageVariant
        }

        //this.message = messageFromEvt ? JSON.stringify(messageFromEvt, null, '\t') : 'no message payload';
        if(this.isDebug) console.log('this.message' , this.message);
    }
}
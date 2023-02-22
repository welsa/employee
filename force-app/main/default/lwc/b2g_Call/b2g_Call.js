import { LightningElement, api } from 'lwc';

export default class B2g_Call extends LightningElement {
    @api callNumber;
    @api callMsg;
}
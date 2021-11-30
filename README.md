# Auction
Functionality for all kinds of auctions, where people compete to acquire various assets

## Overview
Once installed will be use methods:

<table>
<thead>
	<tr>
		<th>method name</th>
		<th>called by</th>
		<th>description</th>
	</tr>
</thead>
<tbody>
	<tr>
		<td><a href="#create">create</a></td>
		<td>anyone</td>
		<td>creation auction</td>
	</tr>
	<tr>
		<td><a href="#bid">bid</a></td>
		<td>anyone</td>
		<td>making bid for action creted before</td>
	</tr>
	<tr>
		<td><a href="#cancel">cancel</a></td>
		<td>owner</td>
		<td>canceling auction</td>
	</tr>
	<tr>
		<td><a href="#finish">finish</a></td>
		<td>owner</td>
		<td>finishing auction</td>
	</tr>
	<tr>
		<td><a href="#withdraw">withdraw</a></td>
		<td>owner</td>
		<td>withdraw fund to someone</td>
	</tr>
	<tr>
		<td><a href="#transferownership">transferOwnership</a></td>
		<td>owner</td>
		<td>transferOwnership</td>
	</tr>
    <tr>
		<td><a href="#setdefaultdata">setDefaultData</a></td>
		<td>owner</td>
		<td>set default settings</td>
	</tr>
    <tr>
		<td><a href="#setdefaultdata">prolong</a></td>
		<td>owner</td>
		<td>prolonging expired auction</td>
	</tr>
	<tr>
		<td><a href="#getwinner">getWinner</a></td>
		<td>anyone</td>
		<td>view auction's winner</td>
	</tr>
	<tr>
		<td><a href="#gethistory">getHistory</a></td>
		<td>anyone</td>
		<td>view history of bids</td>
	</tr>
</tbody>	
</table>

## Methods

#### create
creating auction and make first bid
Params:    
name  | type | description
--|--|--
id|uint256|auction id

#### bid
making bid for auction with `id`
Params:    
name  | type | description
--|--|--
id|uint256|auction id

#### cancel
canceling auction with `id`
Params:    
name  | type | description
--|--|--
id|uint256|auction id

#### finish
finishing auction with `id`
Params:    
name  | type | description
--|--|--
id|uint256|auction id

#### withdraw
transfer funds from last bid auction `id` to address `to`
Params:    
name  | type | description
--|--|--
id|uint256|auction id
to|address|address 

#### transferOwnership
transferOwnership to address `to`
Params:    
name  | type | description
--|--|--
to|address|address 

#### setDefaultData
method will set default settings
Params:    
name  | type | description
--|--|--
duration|uint256|duration
minimumBid|uint256|minimumBid
minimumIncrease|uint256|minimumIncrease

#### prolong
prolonging еxpired auction `id` for `duration`
Params:    
name  | type | description
--|--|--
id|uint256|auction id

#### getWinner
view winner of auction `id`
Params:    
name  | type | description
--|--|--
id|uint256|auction id

#### getHistory
view history of bids by auction `id`
Params:    
name  | type | description
--|--|--
id|uint256|auction id

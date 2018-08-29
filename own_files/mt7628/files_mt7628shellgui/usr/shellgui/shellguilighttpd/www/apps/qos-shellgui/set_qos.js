  //TODO GLOBAL VARS
  var origin_data,rule_data,service_class_data,classes,default_class,total_bw,load,updateLoadInterval,ccstatus,target_ip,ping_limit;

  var d=new Date();
  var lasttime=d.getTime();


  function mapRuleData(data){
    var res = [];
  	for(var i=0; i<data.length; i++){
      var resi = {};
      resi["Set_Service_Class_To"] = data[i].class;
      resi['order'] = data[i].test_order/100;
      if(data[i].srcport){
        resi['Source_Ports'] = data[i].srcport;
      }
      if(data[i].connbytes_kb){
        resi['Connection_bytes_reach'] = data[i].connbytes_kb;
      }
      if(data[i].source){
        resi['Source_IP'] = data[i].source;
      }
      if(data[i].destination){
        resi['Destination_IP'] = data[i].destination;
      }
      if(data[i].dstport){
        resi['Destination_Ports'] = data[i].dstport;
      }
      if(data[i].max_pkt_size){
        resi['Maximum_Packet_Length'] = data[i].max_pkt_size;
      }
      if(data[i].min_pkt_size){
        resi['Minimum_Packet_Length'] = data[i].min_pkt_size;
      }
      if(data[i].proto){
        resi['Transport_Protocol'] = data[i].proto;
      }
      if(data[i].layer7){
        resi['Application__Layer7__Protocol'] = data[i].layer7;
      }
      res.push(resi);
    }
    return res;
  }

  function unmapRuleData(data){
    var res = [];
    for(var i=0; i<data.length; i++){
      var resi = {};
      resi.class = data[i]['Set_Service_Class_To'];
      resi.test_order = data[i]['order']*100;
      if(data[i]['Source_Ports']){
        resi.srcport = data[i]['Source_Ports'];
      }
      if(data[i]['Connection_bytes_reach']){
        resi.connbytes_kb = data[i]['Connection_bytes_reach'];
      }
      if(data[i]['Source_IP']){
        resi.source = data[i]['Source_IP'];
      }
      if(data[i]['Destination_IP']){
        resi.destination = data[i]['Destination_IP'];
      }
      if(data[i]['Destination_Ports']){
        resi.dstport = data[i]['Destination_Ports'];
      }
      if(data[i]['Maximum_Packet_Length']){
        resi.max_pkt_size = data[i]['Maximum_Packet_Length'];
      }
      if(data[i]['Minimum_Packet_Length']){
        resi.min_pkt_size = data[i]['Minimum_Packet_Length'];
      }
      if(data[i]['Transport_Protocol']){
        resi.proto = data[i]['Transport_Protocol'];
      }
      if(data[i]['Application__Layer7__Protocol']){
        resi.layer7 = data[i]['Application__Layer7__Protocol'];
      }
      res.push(resi);
    }

    return res;
  }

  function resetForm(id){
    var form = $('#' + id);
    form.find('input,select').prop('disabled',true);
    form.find('[name="Set_Service_Class_To"]').prop('disabled',false);
    form.find('option').prop('selected',false);
    form.find('input').val('');
    form.find('[type="checkbox"]').prop({'checked':false, 'disabled': false});
    form.find('[type="hidden"]').prop('disabled',false);
  }

  function formatData(data){
    var res = {};
    for(var i=0; i<data.length; i++){
      var name = data[i].name;
      if(name != 'Source_IP' && name != 'Destination_IP'){
        var value = parseInt(data[i].value) || data[i].value;
      }else{
        var value = data[i].value;
      }
      res[name] = value;
    }
    return res;
  }

  function updateLoad(data){
    $('.load_container').each(function(index){
      for(var i=0; i<data.length; i++){
        if($(this).attr('data-class')-1 == i){
          $(this).html(bpsToKbpsString(data[i]));
        }
      }
    });
  }

  function bpsToKbpsString(bps){
    var kbps = '*';
    var bpsn = parseInt(bps)/1000;
    if (isNaN(bpsn))
    {
      kbps = '*';
    }
    else if (bpsn < 1)
    {
      kbps = bpsn.toFixed(1) + '';
    } 
    else
    {
      kbps = bpsn.toFixed(0) + '';
    }
    return kbps;
  }

  function initLoadPbs(data){
    var load = {
      bps: [],
      bytes: [],
      leaf: []
    };
    for(var i=0; i<data.length; i++){
      var bps = null;
      var bytes = NaN;
      var leaf = null;
      load.bps.push(bps);
      load.bytes.push(bytes);
      load.leaf.push(leaf);
    }
    return load;
  }

  function removeSerClass(id,origin){
    var data = [];
    for(var i=0; i<origin.length; i++){
      if(origin[i]['name'] != id){
        data.push(origin[i]);
      }
    }
    return data;
  }

  function makeDefaultClass(data,ud){
    $('#default_class').empty();
    $('#service_class_' + ud).empty();
    for(var i=0; i<data.length; i++){
      if(ud == 'down'){
        var dom = '<option value="dclass_' + data[i][0] + '">' + data[i][1] + '</option>';
      }else if(ud == 'up'){
        var dom = '<option value="uclass_' + data[i][0] + '">' + data[i][1] + '</option>';
      }
      $('#default_class').append(dom);
      $('#service_class_' + ud).append(dom);
    }
  }

  function getClassName(id,data){
    var name;
    for( var i=0; i<data.length; i++){
      if(data[i][0] == id.split('_').pop()){
        name = data[i][1];
      }
    }
    return name;
  }

  function getClassId(data){
    var res = [];
    for(var i=0; i<data.length; i++){
      var class_item = [];
      class_item[0] = data[i].class;
      class_item[1] = data[i].name;
      res.push(class_item);
    }
    return res;
  }

  function moveRuleDown(id,origin){
    if(id == origin.length){
      return origin;
    }
    var data = origin[id-1];
    var data_down = origin[id];
    data['order'] = id+1;
    data_down['order'] = id;
    origin[id-1] = data_down;
    origin[id] = data;
    return origin;
  }

  function moveRuleUp(id,origin){
    if(id==1){
      return origin;
    }
    var data = origin[id-1];
    var data_up = origin[id-2];
    data['order'] = id-1;
    data_up['order'] = id;
    origin[id-1] = data_up;
    origin[id-2] = data;
    return origin;
  }

  function removeRule(id,origin){
    var data = [];
    for(var i=0; i<origin.length; i++){
      if(origin[i]['order'] < id){
        data.push(origin[i]);
      }else if(origin[i]['order'] > id){
        origin[i]['order'] -= 1;
        data.push(origin[i]);
      }
    }
    return data;
  }



function updateLoadData(ud){
    var data;
    if(ud == 'up'){
       data = 'app=qos-shellgui&action=get_' + ud + 'load_speed&wan=' +  currentWanIf;
    }else if (ud == 'down'){
       data = 'app=qos-shellgui&action=get_' + ud + 'load_speed';
    }
    $.post('/', data,function(data){
      var lines = data.match(/hfsc\s1:[0-9]{1,2}\s.+leaf.+\n.+Sent\s[0-9]+/g);
      var d=new Date();
      var timediff=d.getTime()-lasttime;
      lasttime=d.getTime();
      if (lines != null)
      {
        for(i = 0; i < lines.length; i++)
        {
          var idx=parseInt(lines[i].match(/hfsc\s1:([0-9]+)/)[1])-2;
          var lastbytes;
          if (idx < load.bps.length) {
            lastbytes = load.bytes[idx];
            load.bytes[idx]=lines[i].match(/Sent\s([0-9]+)/)[1];
            load.leaf[idx]=lines[i].match(/leaf\s([0-9a-f]*)/)[1];

            if (lastbytes != null)
            {
                load.bps[idx]= (parseInt(load.bytes[idx])-parseInt(lastbytes))*8000/timediff;
            }
            else
            {
                load.bps[idx]=NaN;
            }

          }
        }
        updateLoad(load.bps);
      }
    });
  }

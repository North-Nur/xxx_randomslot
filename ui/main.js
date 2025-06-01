document.addEventListener('DOMContentLoaded', (event) => {
    let url = 'nui://Fxw_inventory/html/img/items/'
    let Random = false 
    const audio = new Audio();
    audio.src = "./sound/random.mp3";
   
    window.addEventListener('message', function(event) {
          if(event.data.action == 'syncR'){
          $('[data-reward = "'+event.data.item+'"]').find('.remaining').html(event.data.count)
          if (event.data.empty){
            $('[data-reward = "'+event.data.item+'"]').addClass('empty')
          }
        }
        if(event.data.action == 'random'){
            Random = true 
            // $('.infinit_in').css('animation','idle .6s linear infinite')
            const totalItems = $('.slot_show').length; // จำนวนไอเท็มทั้งหมด (รวมไอเท็มซ้ำ)
            const centerOffset = Math.floor(3 / 2); // ตำแหน่งกลาง (สำหรับ 3 ช่อง = 1)
            console.log(totalItems)
            // สุ่มตำแหน่งเป้าหมาย
            $('.display_slot_mc').addClass('phase_random')
            const randomIndex = event.data.index; // -3 เพราะไอเท็มซ้ำท้าย
            // console.log(randomIndex)
            const targetPosition = (randomIndex - centerOffset) * itemHeight; // ตำแหน่งเป้าหมายในหน่วย vh
            randomAll(totalItems,5200, randomIndex, centerOffset)

            // audio.src = "./sound/random.mp3";

            // audio.play()
            // audio.volume = 0.5;
        }
        if(event.data.action == 'syncCount'){
          $('.count_random').html(event.data.count)
        }
        if(event.data.action == 'display'){
          if(event.data.bool){
            if(event.data.data){
              $('.title_ui').html(event.data.title)
              $('.img_random').attr('src',url+event.data.itemneed +'.png')
              $('.count_random').html(event.data.count)
              $('.innerandom').empty()
              $('.item_rec_overflow').empty()
              for (key in event.data.data){
                  $('.innerandom').append(`
                     <div class="item_slot_01 slot_show" data-item = "${event.data.data[key].key}" data-key = "${key}" data-label = "${event.data.data[key].value[2]}" >
                        <img src="${url+event.data.data[key].key}.png" alt="">
                     </div>  
                  `)
                  $('.item_rec_overflow').append(
                    `
                     <div class="item_rec_01 ${event.data.data[key].value[0] >= event.data.data[key].value[1] ? `empty` : ''}" data-reward = "${event.data.data[key].key}">
                        <img src="${url+event.data.data[key].key}.png" alt="">
                        <div class="item_limit">
                          <p class ="remaining">${event.data.data[key].value[0]}</p>
                          <p>${event.data.data[key].value[1]}</p>
                        </div>
                        <div class="item_name">
                          <p>${event.data.data[key].value[2]}</p>
                        </div>
                    </div>
                    
                    `
                )
              }
              for (key in event.data.data){
                if (key <=2){
                  $('.innerandom').append(`
                    <div class="item_slot_01 slot_show" >
                       <img src="${url+event.data.data[key].key}.png" alt="">
                    </div>  
                 `)
                }
            }
          }
          $('.display_slot_mc').fadeIn()
          }
          else{
            $('.display_slot_mc').fadeOut()
          }
        }
        

    })


    // ALL ACTION 
 
  let isSpinning = false;

  $('body').on('click', '.spin_btn', function () {
    // if (isSpinning) return; // ห้ามหมุนซ้ำถ้ากำลังหมุนอยู่
    // isSpinning = true;
    $.post(`https://${GetParentResourceName()}/random`, JSON.stringify({
    }))
    audio.src = "./sound/click.mp3";

    audio.play()
    audio.volume = 1;
    // เริ่มหมุน
    // settoIndex( randomIndex, centerOffset , totalItems);
  });
  $('body').on('click', '.enter_btn', function () {
    // if (isSpinning) return; // ห้ามหมุนซ้ำถ้ากำลังหมุนอยู่
    // isSpinning = true;
    audio.src = "./sound/finish.mp3";

    audio.play()
    audio.volume = 0.5;
    setTimeout(() => {
      $('.spin_btn').removeClass('block')

    }, 300);
    Random = false 
    $.post(`https://${GetParentResourceName()}/enter`, JSON.stringify({
    }))
    $('.display_slot_mc').removeClass('phase_finish')

    // $('.item_finish_area').fadeOut()
    // เริ่มหมุน
    // settoIndex( randomIndex, centerOffset , totalItems);
  });
  const itemHeight = 15; // ความสูงของแต่ละไอเท็ม (vh)
 
  // function settoIndex( randomIndex, centerOffset , totalItems){
  //   if (randomIndex == 0 ){
  //       var finalPosition = ((totalItems - 3) - centerOffset) * itemHeight;
  //       finalPosition = finalPosition + 7.5
  //       $('.innerandom').css('transform', `translateY(${-finalPosition}vh)`);
  //       // $('.innerandom').css('transition', 'transform 0.3s ease-out'); // เปิด transition
  //   }
  //   else{
  //       var finalPosition = (randomIndex - centerOffset) * itemHeight;
  //       finalPosition = finalPosition + 7.5
  //       $('.innerandom').css('transform', `translateY(${-finalPosition}vh)`);
  //       // $('.innerandom').css('transition', 'transform 0.3s ease-out'); // เปิด transition
  //   }
 
  // }
 
  function randomAll(totalItems, Time, randomIndex, centerOffset) {
    const totalHeight = itemHeight * (totalItems - 3); // ความสูงรวมของไอเท็ม
    const spinDuration = Time; // ระยะเวลาหมุน (ms)
    let currentPosition = 0; // ตำแหน่งปัจจุบันของวงล้อ
    let elapsedTime = 0; // เวลาที่ผ่านไป
    let currentSpeed = 3; // ความเร็วเริ่มต้น
    const maxSpeed = 12; // ความเร็วสูงสุด
    const minSpeed = 0.2; // ความเร็วต่ำสุด
    const accelerateDuration = spinDuration * 0.4; // เวลาสำหรับเร่งความเร็ว (40% ของเวลาทั้งหมด)
    const decelerateDuration = spinDuration * 0.6; // เวลาสำหรับลดความเร็ว (60% ของเวลาทั้งหมด)
    setTimeout(() => {
      audio.src = "./sound/click_menu.wav";

      audio.play()
      audio.volume = 1;
      setTimeout(() => {
        audio.src = "./sound/click_menu.wav";
  
        audio.play()
        audio.volume = 1;
        setTimeout(() => {
          audio.src = "./sound/click_menu.wav";
    
          audio.play()
          audio.volume = 1;
        }, 200);
      }, 300);
    }, 400);
    // คำนวณตำแหน่งเป้าหมาย
    const baseIndex = randomIndex === 0 ? (totalItems - 3) : randomIndex;
    const targetPosition = (baseIndex - centerOffset) * itemHeight + 7.5;
    let check = false 
    let CurrentSound = 0
    const Timmer = setInterval(() => {
        elapsedTime += 16; // อัพเดตเวลา (16ms ต่อเฟรม ประมาณ 60FPS)

        if (elapsedTime < accelerateDuration) {
            // ช่วงเร่งความเร็ว
            const progress = elapsedTime / accelerateDuration;
            currentSpeed = maxSpeed * progress; // เพิ่มความเร็วตาม progress
        } else if (elapsedTime < spinDuration) {
            // ช่วงลดความเร็ว
            const progress = (elapsedTime - accelerateDuration) / decelerateDuration;
            currentSpeed = maxSpeed - (maxSpeed - minSpeed) * progress; // ลดความเร็วตาม progress
            // console.log(currentSpeed)
            var sp = maxSpeed - currentSpeed
           
            // $('.infinit_in').css('animation','idle '+currentSpeed+'s linear infinite')
        } else {
        
            // หลังครบเวลา ตรวจสอบว่าถึงตำแหน่งเป้าหมายหรือยัง
            if (Math.abs(currentPosition - targetPosition) <= 1) { // ถ้าตำแหน่งใกล้เป้าหมายพอ
              audio.src = "./sound/click_menu.wav";

              audio.play()
              audio.volume = 1;
                clearInterval(Timmer);
               
                $('.innerandom').css({
                    transform: `translateY(${-targetPosition}vh)`,
                    // transition: 'transform 0.3s ease-out', // เพิ่ม transition สำหรับการปรับตำแหน่ง
                });
                $('.infinit_in').css('animation','')

                setTimeout(() => {
                  $('.img_reward').attr('src',url+$('[data-key = "'+randomIndex+'"]').data('item')+'.png')
                  $('.name_reward').html($('[data-key = "'+randomIndex+'"]').data('label'))
                 
                  setTimeout(() => {
                    $('.display_slot_mc').removeClass('phase_random')
                    $('.display_slot_mc').addClass('phase_finish')
                    // $('.item_finish_area').fadeIn()
                  }, 500);
                  // $('.item_finish_area').css('opacity',1)
                  // $('.item_finish_area').fadeIn()
                }, 500);
              
                // console.log("CLEAR - Reached Target");
                return;
            }
        }

        // อัพเดตตำแหน่งระหว่างหมุน
        currentPosition += currentSpeed;
        CurrentSound += currentSpeed
        // console.log(currentPosition)
        // if (Math.round(currentPosition)%15 == 0 ){
        //   if (audio.ended || audio.paused) {
        //     audio.src = "./sound/tink.wav";

        //     audio.play()
        //     audio.volume = 0.5;
        //   }
         
        // }
        if (CurrentSound >= totalHeight/3) {
          audio.src = "./sound/click_menu.wav";

          audio.play()
          audio.volume = 1;
          CurrentSound = 0 ;
        }
        if (currentPosition >= totalHeight) {
         
            currentPosition = 0; // วนกลับเมื่อเกินความสูงทั้งหมด
        }
        $('.innerandom').css('transform', `translateY(${-currentPosition % totalHeight}vh)`);
    }, 16);
}



  
  


    document.onkeyup = function (data) {
        if (data.which == 27 ) {
          if(Random){

          }
          else{
            $.post(`https://${GetParentResourceName()}/exit`, JSON.stringify({
            }))
          }
           
        }
    }

   



})




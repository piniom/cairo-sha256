use core::traits::Into;
use core::option::OptionTrait;
use core::traits::TryInto;
use core::array::SpanTrait;
use alexandria_math::sha256::sha256 as old_sha256;
use core::sha256::compute_sha256_u32_array;
use core::ArrayTrait;

// 1: Array<u8> -> (Array<u32>, u32, u32)
// 2: Array<u32> -> Array<u8>
// Wraper: new_sha256(Array<u8>) -> Array<u8>

fn from_u32Array_to_u8Array(mut data: Span<u32>) -> Array<u8> {
    let mut result = array![];
    loop {
        match data.pop_front() {
            Option::Some(val) => {
                let mut res = (*val & 0xff000000) / 0x1000000;
                result.append(res.try_into().unwrap());
                res = (*val & 0xff0000) / 0x10000;
                result.append(res.try_into().unwrap());
                res = (*val & 0xff00) / 0x100;
                result.append(res.try_into().unwrap());
                res = *val & 0xff;
                result.append(res.try_into().unwrap());
            },
            Option::None => { break; }
        };
    };
    result
}


//Works well, but could be done implemented with a loop(easier for scaling to u64 u128?)
fn u8_arr_to_32_arr(mut data: Span<u8>) -> (Array<u32>, u32, u32){
    // This function takes a mutable slice of u8 (`data`) as input and converts it into an array of u32.
    // It also returns two additional values:
    //  * `last_input_word`: This stores the last partially processed word if the input data ends באמצע (in the middle) of a word.
    //  * `last_input_num_bytes`: This stores the number of bytes from the last partially processed word.

    let mut result= array![];
    let mut last_input_word:u32=0;
    let mut last_input_num_bytes:u32=0;

    loop {
        match (data.pop_front(),data.pop_front(),data.pop_front(),data.pop_front()) {
            (Option::Some(val1),Option::Some(val2),Option::Some(val3),Option::Some(val4)) => {
                let mut value = (*val1).into() * 0x1000000;
                value = value + (*val2).into() * 0x10000;
                value = value + (*val3).into() * 0x100;
                value = value + (*val4).into();
                result.append(value);     
            },
            (Option::None, _, _, _) =>{
                last_input_word=0;
                last_input_num_bytes=0;
                break;
             },
            (Option::Some(val1), Option::None, _, _) =>{
                last_input_word = (*val1).into() * 0x1000000;
                last_input_num_bytes=1;
                break;

            },
            (Option::Some(val1), Option::Some(val2), Option::None, _) => {
                let mut value = (*val1).into() * 0x1000000;
                value += (*val2).into() * 0x10000;
                last_input_word = value;
                last_input_num_bytes=2;
                break;
            },
            (Option::Some(val1), Option::Some(val2), Option::Some(val3), Option::None) =>{
                let mut value = (*val1).into() * 0x1000000;
                value += (*val2).into() * 0x10000;
                value += (*val3).into() * 0x100;
                last_input_word = value;
                last_input_num_bytes=3;
                break;
            }
        };
    };
    (result,last_input_word,last_input_num_bytes)
}

fn main() -> () {
    let input_1 : Array<u32> = array![1]; //u32
    let input_2 = array![0, 0, 0, 1,  0,0,1]; //u8
    let output_1 = expand_slice(compute_sha256_u32_array(input_1, 1, 3));
    let output_2 = old_sha256(input_2);
    println!("input1 = {:?}", output_1);
    println!("input2 =  {:?}", output_2);
    // res = (data_len.into() & 0xff000000000000) / 0x1000000000000;
    // i << 4  ~  i * 2 ^ 4
    // i >> 4  ~  i 
}

fn expand_slice(slice: [u32;8]) -> Array<u32> {
    let [v0, v1, v2, v3, v4, v5, v6, v7] = slice;
    array![v0, v1, v2, v3, v4, v5, v6, v7]
}

#[cfg(test)]
mod tests {
    use super::u8_arr_to_32_arr;
    use super::from_u32Array_to_u8Array;

    #[test]
    fn u8_arr_to_32_arr_single_byte_overflow() {
        let input: Array<u8> = array![1, 2, 3, 4, 5, 6, 7, 8, 9];
        let (result, last_input_word, last_input_num_bytes) = u8_arr_to_32_arr(input.span());

        assert_eq!(result, array![0x01020304, 0x05060708]);
        assert_eq!(last_input_word, 0x09000000); // Expecting 0x09 as the MSB
        assert_eq!(last_input_num_bytes, 1); // Expecting 0x09 as the MSB
    }

    #[test]
    fn u8_arr_to_32_arr_two_bytes_overflow() {
        let input: Array<u8> = array![1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
        let (result, last_input_word, last_input_num_bytes) = u8_arr_to_32_arr(input.span());

        assert_eq!(result, array![0x01020304, 0x05060708]);
        assert_eq!(last_input_word, 0x090A0000); // Expecting 0x09 as the MSB
        assert_eq!(last_input_num_bytes, 2); // Expecting 0x09 as the MSB
    }

    #[test]
    fn u8_arr_to_32_arr_three_bytes_overflow() {
        let input: Array<u8> = array![1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
        let (result, last_input_word, last_input_num_bytes) = u8_arr_to_32_arr(input.span());

        assert_eq!(result, array![0x01020304, 0x05060708]);
        assert_eq!(last_input_word, 0x090A0B00); // Expecting 0x09 as the MSB
        assert_eq!(last_input_num_bytes, 3); // Expecting 0x09 as the MSB
    }
    #[test]
    fn test_from_u8Array_to_u32Array_python_BIG_ENDIAN() {
        let input: Array<u8> = array![66, 145, 72, 112];
        let (result, last_input_word, last_input_num_bytes) = u8_arr_to_32_arr(input.span());

        assert_eq!(result, array![1116817520]);
        assert_eq!(last_input_word, 0); // Expecting 0x09 as the MSB
        assert_eq!(last_input_num_bytes, 0); // Expecting 0x09 as the MSB


    }
    #[test]
    fn test_from_u8Array_to_u32Array_no_overflow() {
        let input: Array<u8> = array![1, 2, 3, 4, 5, 6, 7, 8];
        let (result, last_input_word, last_input_num_bytes) = u8_arr_to_32_arr(input.span());

        assert_eq!(result, array![0x01020304, 0x05060708]);
        assert_eq!(last_input_word, 0); // Expecting 0x09 as the MSB
        assert_eq!(last_input_num_bytes, 0); // Expecting 0x09 as the MSB

    }



    #[test]
    fn test_from_u32Array_to_u8Array() {
        let input: Array<u32> = array![0x01020304, 0x05060708];
        let result = from_u32Array_to_u8Array(input.span());

        assert_eq!(result, array![1, 2, 3, 4, 5, 6, 7, 8]);
    }

}

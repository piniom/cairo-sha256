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
fn from_u8Array_to_32Array_while(mut data: Span<u8>) -> (Array<u32>, u32, u32) {
    let mut result = array![];
    let mut overflow = 0;

    while let (Option::Some(val1), Option::Some(val2), Option::Some(val3), Option::Some(val4)) = (
        data.pop_front(),
        data.pop_front(),
        data.pop_front(),
        data.pop_front(),
    ) {
        let mut value = (*val1).into() * 0x1000000;
        value += (*val2).into() * 0x10000;
        value += (*val3).into() * 0x100;
        value += (*val4).into();
        result.append(value);
    };

    while let Option::Some(byte) = data.pop_front() {
        overflow *= 256; // Multiply by 2^8 (0x100)
        overflow += (*byte).into();
    };

    (result, overflow, overflow)
}

fn from_u8Array_to_32Array(mut data: Span<u8>)->(Array<u32>,u32,u32) {
    let mut result= array![];
    let mut overflow:u32=0;
    loop {
        match (data.pop_front(),data.pop_front(),data.pop_front(),data.pop_front()) {
            (Option::Some(val1),Option::Some(val2),Option::Some(val3),Option::Some(val4)) => {
                let mut value = (*val1).into() * 0x1000000;
                value = value + (*val2).into() * 0x10000;
                value = value + (*val3).into() * 0x100;
                value = value + (*val4).into();
                result.append(value);     
            },
            (Option::None, _, _, _) =>{break;},
            (Option::Some(val1), Option::None, _, _) =>{
                overflow = (*val1).into() * 0x1000000;
                break;

            },
            (Option::Some(val1), Option::Some(val2), Option::None, _) => {
                let mut value = (*val1).into() * 0x1000000;
                value += (*val2).into() * 0x10000;
                overflow = value;
                break;
            },
            (Option::Some(val1), Option::Some(val2), Option::Some(val3), Option::None) =>{
                let mut value = (*val1).into() * 0x1000000;
                value += (*val2).into() * 0x10000;
                value += (*val3).into() * 0x100;
                overflow = value;
                break;
            }
        };
    };
    (result,overflow,overflow)
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
    use super::from_u8Array_to_32Array;
    use super::from_u8Array_to_32Array_while;
    use super::from_u32Array_to_u8Array;

    #[test]
    fn test_from_u8Array_to_u32Array() {
        let input: Array<u8> = array![1, 2, 3, 4, 5, 6, 7, 8, 9];
        let (result, overflow1, overflow2) = from_u8Array_to_32Array(input.span());

        assert_eq!(result, array![0x01020304, 0x05060708]);
        assert_eq!(overflow1, 0x09000000); // Expecting 0x09 as the MSB

    }

    #[test]
    fn test_from_u32Array_to_u8Array() {
        let input: Array<u32> = array![0x01020304, 0x05060708];
        let result = from_u32Array_to_u8Array(input.span());

        assert_eq!(result, array![1, 2, 3, 4, 5, 6, 7, 8]);
    }
    
    #[test]
    fn test_from_u8Array_to_32Array_while() {
        let input: Array<u8> = array![1, 2, 3, 4, 5, 6, 7, 8, 9];
        let (result, overflow1, overflow2) = from_u8Array_to_32Array_while(input.span());

        assert_eq!(result, array![0x01020304, 0x05060708]);
        assert_eq!(overflow1, 0x09000000); // Expecting 0x09 as the MSB

    }

}

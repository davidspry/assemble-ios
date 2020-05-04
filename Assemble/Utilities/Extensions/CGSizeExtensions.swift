//  CGSizeExtensions.swift
//  Assemble
//
//  Created by David Spry on 9/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

extension CGSize
{
    static func square(_ size: Int) -> CGSize
    {
        return .init(width: size, height: size);
    }
}

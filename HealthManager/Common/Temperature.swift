//
//  Temperature.swift
//  HealthManager
//
//  Created by 赖星果 on 2020/12/28.
//

import GRDB

// 体温
struct Temperature: Codable {
    /// 体温数值
    var num: String = "0"
    /// 日期 yyyy/MM/dd
    var dateString: String?
    /// 时间 hh:mm
    var timeString: String?
    
    /// 设置行名
    private enum Columns: String, CodingKey, ColumnExpression {
        /// 体温数值
        case num
        /// 日期
        case dateString
        /// 时间
        case timeString
    }

}

extension Temperature: MutablePersistableRecord, FetchableRecord {
    /// 获取数据库对象
    private static let dbQueue: DatabaseQueue = DBManager.dbQueue
    
    //MARK: 创建
    /// 创建数据库
    private static func createTable() -> Void {
        try! self.dbQueue.inDatabase { (db) -> Void in
            // 判断是否存在数据库
            if try db.tableExists(TableName.temperature) {
                //debugPrint("表已经存在")
                return
            }
            // 创建数据库表
            try db.create(table: TableName.temperature, temporary: false, ifNotExists: true, body: { (t) in
                // 体温数值
                t.column(Columns.num.rawValue, Database.ColumnType.text)
                // 日期
                t.column(Columns.dateString.rawValue, Database.ColumnType.text)
                // 时间
                t.column(Columns.timeString.rawValue, Database.ColumnType.text)
            })
        }
    }
    
    //MARK: 插入
    /// 插入单个数据
    static func insert(temperature: Temperature) -> Void {
        // 判断是否存在
//        guard Temperature.query(name: student.name!) == nil else {
//            debugPrint("内容重复")
//            // 更新
//            self.update(student: student)
//            return
//        }
        
        // 创建表
        self.createTable()
        // 事务
        try! self.dbQueue.inTransaction { (db) -> Database.TransactionCompletion in
            do {
                var temperatureTemp = temperature
                // 插入到数据库
                try temperatureTemp.insert(db)
                return Database.TransactionCompletion.commit
            } catch {
                return Database.TransactionCompletion.rollback
            }
        }
    }
    
    //MARK: 根据日期查询
    static func query(dateString: String) -> [Temperature]? {
        // 创建数据库
        self.createTable()
        // 返回查询结果
        //var arr:[Temperature]?
        return try! self.dbQueue.unsafeRead({ (db) -> [Temperature] in
            return try Temperature.filter(Column(Columns.dateString.rawValue) == dateString).fetchAll(db)

        })
    }
    
}
